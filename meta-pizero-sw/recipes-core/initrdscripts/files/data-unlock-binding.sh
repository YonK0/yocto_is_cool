
DATA_PART="/dev/mmcblk0p4"          # /data partition (see pizero.wks.in)
DATA_NAME="data"                    # -> /dev/mapper/data
BOOT_KERNEL="/mnt/Image"            # stable /boot artifact we hash (NOT the whole
                                    # FAT: u-boot does saveenv every boot, which
                                    # would make a whole-partition hash unstable)
SECRET_FILE="/etc/data-binding-secret"   # baked into this initramfs (on-card)
KEYFILE="/run/.data.key"            # tmpfs only; removed after use

derive_key() {
    # --- swap THIS function to change the binding (USB token, network, ...) ---
    _boot_hash=$(sha256sum "$BOOT_KERNEL" 2>/dev/null | cut -d' ' -f1)
    _secret=$(cat "$SECRET_FILE" 2>/dev/null)
    [ -n "$_boot_hash" ] && [ -n "$_secret" ] || return 1
    printf '%s%s' "$_boot_hash" "$_secret" | sha256sum | cut -d' ' -f1
}

data_unlock() {
    mkdir -p /run
    if ! ( umask 077; derive_key > "$KEYFILE" ) || [ ! -s "$KEYFILE" ]; then
        echo "data-unlock: key derivation failed; leaving /data locked"
        rm -f "$KEYFILE"
        return 1
    fi

    if cryptsetup isLuks "$DATA_PART" 2>/dev/null; then
        # Normal boot: open the existing container.
        cryptsetup luksOpen --key-file "$KEYFILE" "$DATA_PART" "$DATA_NAME" \
            || echo "data-unlock: open FAILED (re-keyed boot? clone? corrupt?)"
    else
        # First boot: the partition is a blank ext4 from wic; provision LUKS2
        # over it. (Destroys the empty fs — there is nothing to lose yet.)
        echo "data-unlock: provisioning LUKS2 on $DATA_PART (first boot)"
        cryptsetup luksFormat --type luks2 --batch-mode \
            --key-file "$KEYFILE" "$DATA_PART" \
        && cryptsetup luksOpen --key-file "$KEYFILE" "$DATA_PART" "$DATA_NAME" \
        && mkfs.ext4 -q -L data "/dev/mapper/$DATA_NAME" \
        || echo "data-unlock: provisioning FAILED; leaving /data locked"
    fi

    rm -f "$KEYFILE"
}

data_unlock
