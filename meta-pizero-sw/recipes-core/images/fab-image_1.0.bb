DESCRIPTION = "Custom Fab image"
LICENSE = "CLOSED"

require inc/core-base-image.inc

#Using fab distro conf
IMAGE_TYPE = "fab"

# set image root password
# Needs to be removed and replaced with hash directly
ROOT_PASSWORD = "root"
DEV_PASSWORD = "mrrobot"

#-m : add home dir to elliot
EXTRA_USERS_PARAMS  = "groupadd developers; \
                       useradd -m -G developers -p '$(openssl passwd ${DEV_PASSWORD})' elliot; \
                       usermod -p '$(openssl passwd ${ROOT_PASSWORD})' root;"