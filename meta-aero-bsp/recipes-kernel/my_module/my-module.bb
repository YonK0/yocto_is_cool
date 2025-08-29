DESCRIPTION = "My custom kernel module"
LICENSE = "GPL-2.0-only"

SRC_URI = "file://hello.c file://Makefile file://LICENSE"


S = "${UNPACKDIR}"

# Inherit the module class for building kernel modules
inherit module

LIC_FILES_CHKSUM = "file://LICENSE;md5=d1235e54ccbde07b307b638c79b854fe"