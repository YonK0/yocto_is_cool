DESCRIPTION = " Updating bundle recipe for D-bus utility"
LICENSE = "CLOSED"

SRC_URI += " file://install_bundle.py"

S = "${WORKDIR}/sources-unpack"


RDEPENDS:${PN} = "python3-dbus python3-core"

do_install(){
    install -d ${D}${bindir}
    install -m 0755 ${S}/install_bundle.py ${D}${bindir}
}


# Maybe adding this one 
#FILES:${PN} = "${bindir}/install_bundle.py"