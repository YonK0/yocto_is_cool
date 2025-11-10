IMAGE_INSTALL = "basic-packagegroup-core ${CORE_IMAGE_EXTRA_INSTALL}"

inherit core-image
inherit extrausers

#From core-image-minimal
IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE:append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"

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
PREFERRED_PROVIDER_coreutils = "busybox"
RDEPENDS:packagegroup-core-base-utils:remove = "coreutils"
# vi is not enough
IMAGE_INSTALL += "nano"
# Adding sudo package
IMAGE_INSTALL += "sudo"
# Adding our custom sudoers config
IMAGE_INSTALL += "sudo-config"


############################ RAUC integration ###########################
#Required for rauc integration
IMAGE_INSTALL += "rauc rauc-conf"
IMAGE_FSTYPES += "wic ext4 tar.bz2"

#mkfs.ext4 rauc install fail fix:
IMAGE_INSTALL += "e2fsprogs"

# [RAUC] Kernel modules and zimage will be in rootfs ==> uboot init script load kernel from rootfs 
# no need for it , because uboot init script is modified
#IMAGE_INSTALL:append = " kernel-image "

IMAGE_INSTALL += "update-bundle"
IMAGE_INSTALL += "python3"

######################## Storage encryption ###############################
IMAGE_INSTALL += "cryptsetup"

# Adding key to boot partition
# For initramfs to use in rootfs decryption
IMAGE_BOOT_FILES:append = " pass.txt "
