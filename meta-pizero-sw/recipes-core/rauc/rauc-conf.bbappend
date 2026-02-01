FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://bundle-encryption.key"

do_install:append(){
    install -d ${D}${sysconfdir}/rauc
    install -m 600 ${S}/bundle-encryption.key ${D}${sysconfdir}/rauc/
}