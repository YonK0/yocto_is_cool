IMAGE_INSTALL = "basic-packagegroup-core ${CORE_IMAGE_EXTRA_INSTALL}"

inherit core-image


inherit extrausers

#From core-image-minimal
IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE:append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"

#Storage encryption
IMAGE_INSTALL:append = " cryptsetup"

########## Custom kernel module #################
IMAGE_INSTALL += " my-module"
####################################################
#coreutils + bash (default):
# bash, tar, vi, ls, cp, mv, cat, grep, sed, awk, etc.
## Total size: ~15-25MB for all utilities combined
### Licenses: Mix of GPL-2.0 and GPL-3.0
################### VS #############################
#busybox:
#sh, vi, tar, ls, cp, mv, cat, grep, sed, awk, httpd, telnetd, etc.
## Single binary (~1-2MB)
### GPL-2.0 only
######=> busybox >>>> (coreutils + bash):
#####################################################
IMAGE_INSTALL += "busybox"
# vi is not enough
IMAGE_INSTALL += "nano"
# Adding sudo package
IMAGE_INSTALL += "sudo"
# Adding our custom sudoers config
IMAGE_INSTALL += "sudo-config"

#Required for rauc integration
IMAGE_INSTALL += "rauc rauc-conf"
IMAGE_FSTYPES += "wic ext4 tar.bz2"

#mkfs.ext4 rauc install fail fix:
IMAGE_INSTALL += "e2fsprogs"

# Kernel modules and zimage will be in rootfs
IMAGE_INSTALL:append = " kernel-image kernel-modules"

# Remove the kernel from the /boot partition because it is in rootfs
RPI_EXTRA_IMAGE_BOOT_FILES:remove = "${KERNEL_IMAGETYPE}"