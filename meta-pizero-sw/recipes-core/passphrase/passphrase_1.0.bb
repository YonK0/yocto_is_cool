SUMMARY = "A simple recipe to add pass.txt to deploy dir"
DESCRIPTION = ""
LICENSE = "CLOSED"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://pass.txt"

S = "${WORKDIR}/sources-unpack"

inherit deploy

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${S}/pass.txt ${DEPLOYDIR}/pass.txt
}


addtask deploy before do_build after do_install