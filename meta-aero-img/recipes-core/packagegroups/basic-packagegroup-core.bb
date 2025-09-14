SUMMARY = "My Minimal boot requirements"
DESCRIPTION = "This package group is inspired from packagegroup-core-boot"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

# Distro can override the following VIRTUAL-RUNTIME providers:
VIRTUAL-RUNTIME_dev_manager ?= "udev"
VIRTUAL-RUNTIME_keymaps ?= "keymaps"
KEYMAP ?= "fr"

SYSVINIT_SCRIPTS = "modutils-initscripts \
                    ${VIRTUAL-RUNTIME_initscripts} \
                   "

RDEPENDS:${PN} = "\
    base-files \
    base-passwd \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${@bb.utils.contains("DISTRO_FEATURES", "sysvinit", "${SYSVINIT_SCRIPTS}", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "keyboard", "${VIRTUAL-RUNTIME_keymaps}", "", d)} \
    netbase \
    ${VIRTUAL-RUNTIME_login_manager} \
    ${VIRTUAL-RUNTIME_init_manager} \
    ${VIRTUAL-RUNTIME_dev_manager} \
    ${VIRTUAL-RUNTIME_update-alternatives} \
    ${MACHINE_ESSENTIAL_EXTRA_RDEPENDS}"

RRECOMMENDS:${PN} = "\
    ${VIRTUAL-RUNTIME_base-utils-syslog} \
    ${MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS} \
    ${@bb.utils.contains("DISTRO_FEATURES", "sysvinit", "init-ifupdown", "", d)} \
    ${@bb.utils.contains("DISTRO_FEATURES", "sysvinit pni-names", "ifupdown", "", d)} \
    "
