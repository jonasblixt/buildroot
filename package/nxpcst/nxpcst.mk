################################################################################
#
# NXP Code signing tool
#
################################################################################

NXPCST_VERSION = v0.1.1
NXPCST_SITE = https://github.com/jonasblixt/nxpcst.git
NXPCST_SITE_METHOD = git
NXPCST_INSTALL_STAGING = YES
NXPCST_LICENSE = BSD-3-Clause
NXPCST_LICENSE_FILES = License.txt
NXPCST_AUTORECONF = YES

$(eval $(host-autotools-package))
