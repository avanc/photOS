################################################################################
#
# mautrix
#
################################################################################

PYTHON_MATRIX_PHOTOS_VERSION = 0.0.1b1
PYTHON_MATRIX_PHOTOS_SOURCE = matrix-photos-$(PYTHON_MATRIX_PHOTOS_VERSION).tar.gz
PYTHON_MATRIX_PHOTOS_SITE = https://files.pythonhosted.org/packages/a1/0d/1feda8bef04b537b24b9e0cc8491d77c92210ba05ed60f80b98060a9dec5

PYTHON_MATRIX_PHOTOS_SETUP_TYPE = setuptools

$(eval $(python-package))
