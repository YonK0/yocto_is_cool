#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

fail() {
    echo "initramfs FATAL: $*"
    echo "Dropping to a shell. (Unattended units should be configured to reset.)"
    exec /bin/sh
}

mkdir -p /proc /sys /dev /mnt /rootfs
mount -t proc     proc     /proc
mount -t sysfs    sysfs    /sys
mount -t devtmpfs devtmpfs /dev

# --- read kernel cmdline -----------------------------------------------------
# U-Boot (boot.cmd) selects the slot and appends, per the requirement, the root
# hash on the kernel command line:
#   root=/dev/mmcblk0pN rauc.slot=A|B verity.roothash=<hex> verity.datasize=<bytes>
ROOTDEV=""; SLOT=""; ROOTHASH=""; DATASIZE=""
for arg in $(cat /proc/cmdline); do
    case "$arg" in
        root=*)             ROOTDEV="${arg#root=}" ;;
        rauc.slot=*)        SLOT="${arg#rauc.slot=}" ;;
        verity.roothash=*)  ROOTHASH="${arg#verity.roothash=}" ;;
        verity.datasize=*)  DATASIZE="${arg#verity.datasize=}" ;;
    esac
done
[ -n "$ROOTDEV" ]  || fail "no root= on cmdline"
[ -n "$ROOTHASH" ] || fail "no verity.roothash= on cmdline"
[ -n "$DATASIZE" ] || fail "no verity.datasize= on cmdline"

# /boot is needed by the /data binding (it hashes the kernel Image there).
mount -o ro /dev/mmcblk0p1 /mnt || fail "mount /boot"

# --- Job 1: INTEGRITY --------------------------------------------------------
echo "initramfs: opening dm-verity rootfs on $ROOTDEV (slot ${SLOT:-?})"
veritysetup open "$ROOTDEV" rootfs "$ROOTDEV" "$ROOTHASH" \
        --hash-offset="$DATASIZE" \
    || fail "dm-verity open failed -- ROOTFS TAMPERED or root hash mismatch"

mount -o ro /dev/mapper/rootfs /rootfs || fail "mount verity rootfs"
[ -d /rootfs/sbin ] || fail "verity rootfs sanity check failed"

# --- Job 2: CONFIDENTIALITY --------------------------------------------------
if [ -f /data-unlock-binding.sh ]; then
    . /data-unlock-binding.sh || echo "initramfs: WARN /data not unlocked"
else
    echo "initramfs: WARN data-unlock-binding.sh missing; /data stays locked"
fi

# --- hand over ---------------------------------------------------------------
umount /mnt  2>/dev/null
umount /sys  2>/dev/null
umount /proc 2>/dev/null
echo "initramfs: switch_root -> /sbin/init"
exec switch_root /rootfs /sbin/init
