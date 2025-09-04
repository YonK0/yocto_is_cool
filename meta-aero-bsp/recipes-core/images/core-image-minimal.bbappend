remove_unwanted_services(){
    rm -f ${IMAGE_ROOTFS}/etc/init.d/networking
    echo "-->removing ${IMAGE_ROOTFS}/rootfs/etc/init.d/networking"
    rm -f ${IMAGE_ROOTFS}/etc/init.d/banner.sh

    rm -f ${IMAGE_ROOTFS}/etc/rc*.d/*networking
    rm -f ${IMAGE_ROOTFS}/etc/rc*.d/*banner
}

ROOTFS_POSTPROCESS_COMMAND:append = " \
  remove_unwanted_services; \
"
