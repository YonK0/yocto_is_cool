SUMMARY = "RAUC bundle generator recipe"
DESCRIPTION = "RAUC bundle generator"
LICENSE = "CLOSED"

inherit bundle

RAUC_BUNDLE_COMPATIBLE = "${MACHINE}"

RAUC_BUNDLE_FORMAT = "crypt"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "dev-image"
RAUC_SLOT_rootfs[fstype] = "ext4"
RAUC_SLOT_rootfs[adaptive] = "block-hash-index"