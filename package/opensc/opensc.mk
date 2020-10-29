################################################################################
#
# opensc
#
################################################################################

OPENSC_VERSION = 0.20.0
OPENSC_SITE = https://github.com/OpenSC/OpenSC/releases/download/$(OPENSC_VERSION)
OPENSC_LICENSE = LGPL-2.1+
OPENSC_LICENSE_FILES = COPYING
OPENSC_INSTALL_STAGING = YES
OPENSC_DEPENDENCIES = libusb pcsc-lite

$(eval $(autotools-package))
