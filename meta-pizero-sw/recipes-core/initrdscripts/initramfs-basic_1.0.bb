SUMMARY = "Basic initramfs "
DESCRIPTION = ""
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://boot.sh \
           file://data-unlock-binding.sh \
           file://binding-secret"

S = "${WORKDIR}/sources-unpack"
do_install() {
    # Install init script
    install -m 0755 ${WORKDIR}/sources-unpack/boot.sh ${D}/init

    # Install the isolated /data unlock binding (sourced by /init) and the
    # on-card secret it bakes into the KDF. See data-unlock-binding.sh header:
    # this is the deliberately-weak, swappable link.
    install -m 0755 ${WORKDIR}/sources-unpack/data-unlock-binding.sh ${D}/data-unlock-binding.sh
    install -d ${D}/etc
    install -m 0400 ${WORKDIR}/sources-unpack/binding-secret ${D}/etc/data-binding-secret

    # Create essential directories
    install -d ${D}/dev
    install -d ${D}/proc
    install -d ${D}/sys

    # Create device nodes
    mknod -m 622 ${D}/dev/console c 5 1
    mknod -m 666 ${D}/dev/null c 1 3
}

FILES:${PN} = "/init /data-unlock-binding.sh /etc/data-binding-secret /dev /proc /sys"

PACKAGE_ARCH = "${MACHINE_ARCH}"