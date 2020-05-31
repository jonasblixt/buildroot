################################################################################
#
# Bitpacker
#
################################################################################

BPAK_VERSION = v0.3.4
BPAK_SITE = https://github.com/jonasblixt/bpak.git
BPAK_SITE_METHOD = git
BPAK_INSTALL_STAGING = YES
BPAK_LICENSE = BSD-3-Clause
BPAK_LICENSE_FILES = License.txt
BPAK_AUTORECONF = YES

$(eval $(autotools-package))
$(eval $(host-autotools-package))
