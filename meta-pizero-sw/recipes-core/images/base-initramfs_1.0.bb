SUMMARY = "Extremely basic image initramfs script"
LICENSE = "CLOSED"

PACKAGE_INSTALL = "initramfs-basic \
                   busybox \
                   base-passwd \
                   cryptsetup \
                   e2fsprogs-mke2fs \
                   userland \
                   ${ROOTFS_BOOTSTRAP_INSTALL}"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

# Don't allow the initramfs to contain a kernel
PACKAGE_EXCLUDE = "kernel-image-*"

IMAGE_NAME_SUFFIX ?= ""
IMAGE_LINGUAS = ""

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

# Use the same restriction as initramfs-module-install
COMPATIBLE_HOST = "(x86_64.*|i.86.*|arm.*|aarch64.*|loongarch64.*)-(linux.*|freebsd.*)"
