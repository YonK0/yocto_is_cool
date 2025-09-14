IMAGE_INSTALL = "basic-packagegroup-core ${CORE_IMAGE_EXTRA_INSTALL}"

inherit core-image

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
