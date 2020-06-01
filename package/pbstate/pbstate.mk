################################################################################
#
# Punchboot pbstate
#
################################################################################

PBSTATE_VERSION = v0.7.4
PBSTATE_SITE = https://github.com/jonasblixt/punchboot.git
PBSTATE_SITE_METHOD = git
PBSTATE_INSTALL_STAGING = YES
PBSTATE_LICENSE = BSD-3-Clause
PBSTATE_LICENSE_FILES = License.txt
PBSTATE_DEPENDENCIES = host-autoconf-archive host-pkgconf
PBSTATE_AUTORECONF = YES
PBSTATE_AUTORECONF_OPTS = --include=$(HOST_DIR)/share/autoconf-archive
PBSTATE_SUBDIR = tools/pbstate

define PBSTATE_CREATE_M4
	mkdir -p $(@D)/tools/pbstate/m4
endef

PBSTATE_POST_PATCH_HOOKS += PBSTATE_CREATE_M4
HOST_PBSTATE_POST_PATCH_HOOKS += PBSTATE_CREATE_M4

$(eval $(autotools-package))
