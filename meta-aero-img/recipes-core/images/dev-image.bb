DESCRIPTION = "Custom Dev image"
LICENSE = "CLOSED"

require core-base-image.inc

#Using dev distro conf
IMAGE_TYPE = "dev"

# Debugging packages
IMAGE_INSTALL += " \
    gdb \
    strace \
    ldd \
"

# Development packages
IMAGE_INSTALL += " \
    gcc \
    g++ \
    make \
"

#Adding dev and dbg only packages
IMAGE_FEATURES += "dev-pkgs dbg-pkgs"
#Remove root password
IMAGE_FEATURES += "empty-root-password"

IMAGE_FSTYPES += "wic"
#Using custom wks that include /data partition (Instead of sdimage-raspberrypi.wks)
WKS_FILE = "dev-image.wks"