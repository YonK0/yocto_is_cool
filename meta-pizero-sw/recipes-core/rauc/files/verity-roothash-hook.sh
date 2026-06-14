#!/bin/sh
# =============================================================================
#  RAUC slot hook -- refresh the per-slot dm-verity root hash after an OTA.
# =============================================================================

case "$1" in
    slot-post-install)
        # Only the rootfs slots carry a verity hash.
        [ "$RAUC_SLOT_CLASS" = "rootfs" ] || exit 0

        src="${RAUC_BUNDLE_MOUNT_POINT}/verity.env"
        if [ ! -f "$src" ]; then
            echo "verity-hook: $src not in bundle -- cannot refresh root hash" >&2
            exit 1
        fi

        # ROOT_HASH / DATA_SIZE
        # shellcheck disable=SC1090
        . "$src"
        dst="/boot/verity-${RAUC_SLOT_BOOTNAME}.env"
        {
            echo "verity_roothash=${ROOT_HASH}"
            echo "verity_datasize=${DATA_SIZE}"
        } > "$dst" || { echo "verity-hook: cannot write $dst" >&2; exit 1; }
        sync
        echo "verity-hook: refreshed $dst for slot ${RAUC_SLOT_BOOTNAME}"
        ;;
esac
exit 0
