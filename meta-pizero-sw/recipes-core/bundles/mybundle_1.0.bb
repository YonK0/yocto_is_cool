SUMMARY = "RAUC bundle generator recipe"
DESCRIPTION = "RAUC bundle generator"
LICENSE = "CLOSED"

inherit bundle

RAUC_BUNDLE_COMPATIBLE = "${MACHINE}"

RAUC_BUNDLE_FORMAT = "crypt"

# Pull the verity-roothash hook from the rauc recipe's files dir (shared).
FILESEXTRAPATHS:prepend := "${THISDIR}/../rauc/files:"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_TARGET_IMAGE ?= "${IMAGE_TYPE}-image"
RAUC_SLOT_rootfs = "${RAUC_TARGET_IMAGE}"
# Ship the dm-verity image (ext4 + appended hash tree)
RAUC_SLOT_rootfs[fstype] = "ext4.verity"
RAUC_SLOT_rootfs[adaptive] = "block-hash-index"

# After writing the new rootfs into the inactive slot, refresh that slot's
# dm-verity root hash on the boot partition so U-Boot passes the correct hash
# next boot (/boot/verity-<A|B>.env). See verity-roothash-hook.sh.
RAUC_SLOT_rootfs[hooks] = "post-install"
RAUC_BUNDLE_HOOKS[file] = "verity-roothash-hook.sh"
SRC_URI += "file://verity-roothash-hook.sh"

RAUC_BUNDLE_EXTRA_FILES += "verity.env"
RAUC_BUNDLE_EXTRA_DEPENDS += "${RAUC_TARGET_IMAGE}"