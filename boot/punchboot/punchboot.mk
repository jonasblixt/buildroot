PUNCHBOOT_VERSION = 0.9-dev
PUNCHBOOT_SITE = https://github.com/jonasblixt/punchboot.git
PUNCHBOOT_SITE_METHOD = git
PUNCHBOOT_INSTALL_STAGING = YES
PUNCHBOOT_LICENSE = BSD-3-Clause
PUNCHBOOT_LICENSE_FILES = License.txt
PUNCHBOOT_INSTALL_IMAGES = YES
PUNCHBOOT_DEPENDENCIES = host-bpak

define PUNCHBOOT_CONFIGURE_CMDS
		cp $(BR2_PUNCHBOOT_DEFCONFIG) $(@D)/.config
endef

define PUNCHBOOT_BUILD_CMDS
	$(MAKE) -C $(@D)/ CROSS_COMPILE=$(TARGET_CROSS) \
					  BOARD=$(BR2_PUNCHBOOT_BOARD) \
					  BPAK=$(HOST_DIR)/usr/bin/bpak \
					  PYTHON=$(HOST_DIR)/usr/bin/python3 \
					  KEYSTORE_BPAK=$(shell readlink -f $(BR2_PUNCHBOOT_KEYSTORE)) \
					  $(subst ",,$(BR2_PUNCHBOOT_EXTRA_OPTS))
endef

define PUNCHBOOT_INSTALL_IMAGES_CMDS
	$(MAKE) -C $(@D)/ install   CROSS_COMPILE=$(TARGET_CROSS) \
								BOARD=$(BR2_PUNCHBOOT_BOARD) \
								BPAK=$(HOST_DIR)/usr/bin/bpak \
								PYTHON=$(HOST_DIR)/usr/bin/python3 \
								KEYSTORE_BPAK=$(readlink -f $(BR2_PUNCHBOOT_KEYSTORE)) \
								INSTALL_DIR=$(BINARIES_DIR) \
								$(subst ",,$(BR2_PUNCHBOOT_EXTRA_OPTS))
endef

$(eval $(generic-package))
