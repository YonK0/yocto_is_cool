FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/files:"

SRC_URI += "file://minimal.cfg"
SRC_URI += "file://myled-overlay.dts"

do_configure:append() {
    cp ${WORKDIR}/sources-unpack/myled-overlay.dts ${S}/arch/arm/boot/dts/overlays/
    echo "dtbo-$(CONFIG_ARCH_BCM2835) += myled.dtbo"  >> ${S}/arch/arm/boot/dts/overlays/Makefile
}