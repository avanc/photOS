################################################################################
#
# mautrix
#
################################################################################

PYTHON_MATRIX_PHOTOS_VERSION = 0.0.2
PYTHON_MATRIX_PHOTOS_SOURCE = matrix-photos-$(PYTHON_MATRIX_PHOTOS_VERSION).tar.gz
PYTHON_MATRIX_PHOTOS_SITE = https://files.pythonhosted.org/packages/b2/70/267b57ee783cbbc4f268ad9ac208140459b5d97ddec736c6ed1b928f4ab5

PYTHON_MATRIX_PHOTOS_SETUP_TYPE = setuptools

$(eval $(python-package))
