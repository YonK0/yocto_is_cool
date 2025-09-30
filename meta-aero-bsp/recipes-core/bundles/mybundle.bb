DESCRIPTION = "RAUC bundle generator"
LICENSE = "CLOSED"

inherit bundle

RAUC_BUNDLE_COMPATIBLE = "${MACHINE}"

RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "dev-image"
RAUC_SLOT_rootfs[fstype] = "ext4"