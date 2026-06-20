FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://wpa_supplicant-wlan0.conf file://wlan0.network"

SRC_URI:append = " file://brcmfmac.conf"

do_install:append(){
    install -d ${D}${sysconfdir}/wpa_supplicant
    install -m 0600 ${UNPACKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant/wpa_supplicant-wlan0.conf

    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${UNPACKDIR}/wlan0.network ${D}${sysconfdir}/systemd/network/25-wlan0.network

    # workaround : failed to connect to wifi at boot.
    install -d ${D}${sysconfdir}/modprobe.d
    install -m 0644 ${UNPACKDIR}/brcmfmac.conf ${D}${sysconfdir}/modprobe.d/brcmfmac.conf
}

FILES:${PN} += "${sysconfdir}/systemd/network/25-wlan0.network"
FILES:${PN} += "${sysconfdir}/modprobe.d/brcmfmac.conf"

SYSTEMD_SERVICE:${PN} = "wpa_supplicant@wlan0.service"
SYSTEMD_AUTO_ENABLE = "enable"