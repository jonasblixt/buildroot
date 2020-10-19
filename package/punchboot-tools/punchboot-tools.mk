################################################################################
#
# Punchboot tools
#
################################################################################

PUNCHBOOT_TOOLS_VERSION = v0.2.0
PUNCHBOOT_TOOLS_SITE = https://github.com/jonasblixt/punchboot-tools.git
PUNCHBOOT_TOOLS_SITE_METHOD = git
PUNCHBOOT_TOOLS_INSTALL_STAGING = YES
PUNCHBOOT_TOOLS_LICENSE = BSD-3-Clause
PUNCHBOOT_TOOLS_LICENSE_FILES = License.txt
PUNCHBOOT_TOOLS_AUTORECONF = YES
HOST_PUNCHBOOT_TOOLS_DEPENDENCIES = host-libusb host-bpak

$(eval $(host-autotools-package))
