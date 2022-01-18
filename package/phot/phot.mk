################################################################################
#
# phot 
#
################################################################################

PHOT_VERSION = ee11f23
PHOT_SITE = https://codeberg.org/photOS/phot.git
PHOT_SITE_METHOD = git

PHOT_LICENSE = GPL-3.0
PHOT_FILES = LICENSE
PHOT_SETUP_TYPE = setuptools

$(eval $(python-package))
