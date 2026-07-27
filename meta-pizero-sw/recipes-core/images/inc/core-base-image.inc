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

############################ WIC integration ###########################
WKS_FILE = "pizero-image.wks.in"

######################## Storage security ###############################

# --- Job 1: dm-verity, read-only rootfs ---------------------------------
IMAGE_CLASSES += "dm-verity-img"

DM_VERITY_IMAGE = "${PN}"
DM_VERITY_IMAGE_TYPE = "ext4"
IMAGE_FSTYPES += "ext4.verity"
IMAGE_FEATURES += "read-only-rootfs"

deploy_verity_boot_env() {
    venv="${STAGING_VERITY_DIR}/${IMAGE_BASENAME}.${DM_VERITY_IMAGE_TYPE}.verity.env"
    if [ ! -f "${venv}" ]; then
        bbfatal "dm-verity env not found at ${venv} (check dm-verity-img staging)"
    fi
    . "${venv}"   # ROOT_HASH / DATA_SIZE
    for slot in A B; do
        printf 'verity_roothash=%s\nverity_datasize=%s\n' \
            "${ROOT_HASH}" "${DATA_SIZE}" > "${DEPLOY_DIR_IMAGE}/verity-${slot}.env"
    done
    # Also publish the raw env (ROOT_HASH / DATA_SIZE) for the RAUC bundle hook.
    cp "${venv}" "${DEPLOY_DIR_IMAGE}/verity.env"
}

do_image_wic[prefuncs] += "deploy_verity_boot_env"
IMAGE_TYPEDEP:wic += "${DM_VERITY_IMAGE_TYPE}.verity"
IMAGE_BOOT_FILES:append = " verity-A.env verity-B.env"

WICVARS:append = " IMGDEPLOYDIR"

# Encryption tool
IMAGE_INSTALL += "cryptsetup"

# Fixed A/B slot size (MiB). MUST be >= the built ext4.verity image size + 32MiB
ROOTFS_SLOT_SIZE ?= "768"
WICVARS:append = " ROOTFS_SLOT_SIZE"
####################################################

# SSH
IMAGE_FEATURES += "ssh-server-dropbear"

# Add wifi (this board is BCM43430 per dmesg; brcmfmac is a module so it loads
# after the rootfs is mounted and the firmware is reachable)
IMAGE_INSTALL += "linux-firmware-bcm43430 kernel-module-brcmfmac kernel-module-brcmfmac-wcc wpa-supplicant"
