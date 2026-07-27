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

# Keys come from the per-device customer OTP.
. /otp-key.sh

# --- Job 1: CONFIDENTIALITY (LUKS) + INTEGRITY (dm-verity) -------------------
if ! cryptsetup status rootfs_crypt >/dev/null 2>&1; then
    mkdir -p /run; KEYFILE="/run/.rootfs.key"
    if ! ( umask 077; derive_key rootfs > "$KEYFILE" ) || [ ! -s "$KEYFILE" ]; then
        rm -f "$KEYFILE"; fail "OTP key derivation failed for rootfs"
    fi
    if cryptsetup isLuks "$ROOTDEV" 2>/dev/null; then
        cryptsetup luksOpen --key-file "$KEYFILE" "$ROOTDEV" rootfs_crypt \
            || { rm -f "$KEYFILE"; fail "LUKS open failed for $ROOTDEV (wrong OTP key? corrupt?)"; }
    else
        echo "initramfs: encrypting $ROOTDEV in place (first boot)"
        cryptsetup reencrypt --encrypt --type luks2 --batch-mode \
            --reduce-device-size 32M --key-file "$KEYFILE" "$ROOTDEV" \
        && cryptsetup luksOpen --key-file "$KEYFILE" "$ROOTDEV" rootfs_crypt \
        || { rm -f "$KEYFILE"; fail "in-place LUKS encryption failed for $ROOTDEV"; }
    fi
    rm -f "$KEYFILE"
fi

echo "initramfs: opening dm-verity rootfs on /dev/mapper/rootfs_crypt (slot ${SLOT:-?})"
veritysetup open /dev/mapper/rootfs_crypt rootfs /dev/mapper/rootfs_crypt "$ROOTHASH" \
        --hash-offset="$DATASIZE" \
    || fail "dm-verity open failed -- ROOTFS TAMPERED or root hash mismatch"

mount -o ro /dev/mapper/rootfs /rootfs || fail "mount verity rootfs"
[ -d /rootfs/sbin ] || fail "verity rootfs sanity check failed"

# --- Job 2: /data (LUKS2, same OTP key family) -------------------------------
DATA_PART="/dev/mmcblk0p4"; KEYFILE="/run/.data.key"
if ( umask 077; derive_key data > "$KEYFILE" ) && [ -s "$KEYFILE" ]; then
    if cryptsetup isLuks "$DATA_PART" 2>/dev/null; then
        cryptsetup luksOpen --key-file "$KEYFILE" "$DATA_PART" data \
            || echo "initramfs: WARN /data open FAILED (re-keyed? clone? corrupt?)"
    else
        # First boot: provision LUKS2 over the blank wic ext4 (nothing to lose).
        echo "initramfs: provisioning LUKS2 on $DATA_PART (first boot)"
        cryptsetup luksFormat --type luks2 --batch-mode --key-file "$KEYFILE" "$DATA_PART" \
        && cryptsetup luksOpen --key-file "$KEYFILE" "$DATA_PART" data \
        && mkfs.ext4 -q -L data /dev/mapper/data \
        || echo "initramfs: WARN /data provisioning FAILED; left locked"
    fi
else
    echo "initramfs: WARN /data key derivation failed; left locked"
fi
rm -f "$KEYFILE"

# Mount /data here so systemd sees it pre-mounted, instead of blocking ~90s
# waiting for udev to recreate /dev/mapper/data after switch_root.
[ -e /dev/mapper/data ] && mount /dev/mapper/data /rootfs/data 2>/dev/null

# --- hand over ---------------------------------------------------------------
umount /mnt  2>/dev/null
umount /sys  2>/dev/null
umount /proc 2>/dev/null
echo "initramfs: switch_root -> /sbin/init"
exec switch_root /rootfs /sbin/init
