DESCRIPTION = "Custom Dev image"
LICENSE = "CLOSED"

require inc/core-base-image.inc

#Using dev distro conf
IMAGE_TYPE = "dev"

# Debugging packages
#IMAGE_INSTALL += " \
#    gdb \
#    strace \
#    ldd \
#"

# Development packages
#IMAGE_INSTALL += " \
#    gcc \
#    g++ \
#    make \
#"

#Adding dev and dbg only packages
#IMAGE_FEATURES += "dev-pkgs dbg-pkgs"

IMAGE_INSTALL:remove = "kernel-image"
#Remove root password
IMAGE_FEATURES += "empty-root-password"

WKS_FILE = "pizero-image.wks.in"