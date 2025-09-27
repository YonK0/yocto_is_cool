SUMMARY = "Recipe for adding users to sudoers group"
DESCRIPTION = "Recipe for adding users to sudoers group"
LICENSE = "CLOSED"


do_install(){
    install -d ${D}/etc/sudoers.d
    echo "elliot ALL=(ALL) ALL" > ${D}/etc/sudoers.d/devs
    echo "flag{BE_CAREFULL_WHO_IS_SUDOERS}" > ${D}/etc/sudoers.d/flag.txt
    chmod 440 ${D}/etc/sudoers.d/devs
    chmod 644 ${D}/etc/sudoers.d/flag.txt
}