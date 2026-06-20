FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add a mount point for a shared data partition
dirs755 += "/data"

data_part ?= "${@oe.utils.conditional('DATA_ENCRYPTION', '1', '/dev/mapper/data', '/dev/mmcblk0p4', d)}"
do_install:append() {
    sed -i "s#^/dev/mapper/data#${data_part}#" ${D}${sysconfdir}/fstab
}