################################################################################
#
# Kickstart initrd
#
################################################################################

#KICKSTART_INITRD_VERSION = v0.1.0
#KICKSTART_INITRD_SITE = https://github.com/jonasblixt/kickstart-initrd.git
KICKSTART_INITRD_VERSION=41811c4f1fc35214b5204bf11605098b2bac42fe
KICKSTART_INITRD_SITE=/work/kickstart-initrd
KICKSTART_INITRD_SITE_METHOD = git
KICKSTART_INITRD_INSTALL_STAGING = YES
KICKSTART_INITRD_LICENSE = BSD-3-Clause
KICKSTART_INITRD_LICENSE_FILES = License.txt
KICKSTART_INITRD_DEPENDENCIES = host-autoconf-archive host-pkgconf
KICKSTART_INITRD_AUTORECONF = YES
KICKSTART_INITRD_AUTORECONF_OPTS = --include=$(HOST_DIR)/share/autoconf-archive
KICKSTART_INITRD_INSTALL_IMAGES = YES

KICKSTART_INITRD_CONF_ENV = \
	KEYSTORE_FILE=$(BR2_KICKSTART_INITRD_KEYSTORE)

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
	rm -rf initrd
	mkdir -p initrd/proc
	mkdir -p initrd/sys
	mkdir -p initrd/dev
	mkdir -p initrd/tmp
	mkdir -p initrd/newroot
	mkdir -p initrd/data/tee
	cp $(@D)/src/kickstart-initrd initrd/init
	mkdir -p $(BINARIES_DIR)
	cd initrd && find . | cpio -H newc -o > $(BINARIES_DIR)/kickstart-initrd.cpio
endef

$(eval $(autotools-package))
