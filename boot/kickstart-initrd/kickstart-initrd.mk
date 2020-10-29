################################################################################
#
# Kickstart initrd
#
################################################################################

KICKSTART_INITRD_VERSION = 700c5e6adbca680d8dbd9a7e1a613f512cc18a9c
KICKSTART_INITRD_SITE = https://github.com/jonasblixt/kickstart-initrd.git
KICKSTART_INITRD_SITE_METHOD = git
KICKSTART_INITRD_GIT_SUBMODULES = YES
KICKSTART_INITRD_INSTALL_STAGING = YES
KICKSTART_INITRD_LICENSE = BSD-3-Clause
KICKSTART_INITRD_LICENSE_FILES = License.txt
KICKSTART_INITRD_DEPENDENCIES = host-autoconf-archive host-pkgconf
KICKSTART_INITRD_AUTORECONF = YES
KICKSTART_INITRD_AUTORECONF_OPTS = --include=$(HOST_DIR)/share/autoconf-archive
KICKSTART_INITRD_INSTALL_IMAGES = YES

KICKSTART_INITRD_CONF_ENV = \
	KEYSTORE_FILE=$(shell readlink -f $(BR2_KICKSTART_INITRD_KEYSTORE))

KICKSTART_INITRD_CONF_OPTS = \
	CFLAGS="-static" \

define KICKSTART_INITRD_INSTALL_IMAGES_CMDS
	#strip -C $(@D)/kickstart-initrd
endef

define KICKSTART_INITRD_CREATE_M4
	mkdir -p $(@D)/m4
endef

KICKSTART_INITRD_POST_PATCH_HOOKS += KICKSTART_INITRD_CREATE_M4

define KICKSTART_INITRD_INSTALL_TARGET_CMDS
	rm -f $(BINARIES_DIR)/kickstart-initrd.cpio
	rm -rf $(@D)/initrd
	mkdir -p $(@D)/initrd/proc
	mkdir -p $(@D)/initrd/sys
	mkdir -p $(@D)/initrd/dev
	mkdir -p $(@D)/initrd/tmp
	mkdir -p $(@D)/initrd/target
	cp $(@D)/src/kickstart-initrd $(@D)/initrd/init
	cp $(BR2_KICKSTART_INITRD_CONF) $(@D)/initrd/ksinitrd.conf

	test -n $(BR2_KICKSTART_INITRD_OVERLAY) && \
		cp -aR $(BR2_KICKSTART_INITRD_OVERLAY)/* $(@D)/initrd/ || \
		true

	mkdir -p $(BINARIES_DIR)
	cd $(@D)/initrd && find . | cpio -H newc -o > $(BINARIES_DIR)/kickstart-initrd.cpio
endef

$(eval $(autotools-package))
