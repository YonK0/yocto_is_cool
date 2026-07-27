SUMMARY = "Basic initramfs "
DESCRIPTION = ""
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://boot.sh \
           file://otp-key.sh"

S = "${WORKDIR}/sources-unpack"
do_install() {
    # Install init script and the OTP key helper it sources (rootfs + /data LUKS
    # keys are derived from the per-device customer OTP). See otp-key.sh.
    install -m 0755 ${WORKDIR}/sources-unpack/boot.sh ${D}/init
    install -m 0755 ${WORKDIR}/sources-unpack/otp-key.sh ${D}/otp-key.sh

    # Create essential directories
    install -d ${D}/dev
    install -d ${D}/proc
    install -d ${D}/sys

    # Create device nodes
    mknod -m 622 ${D}/dev/console c 5 1
    mknod -m 666 ${D}/dev/null c 1 3
}

FILES:${PN} = "/init /otp-key.sh /dev /proc /sys"

PACKAGE_ARCH = "${MACHINE_ARCH}"