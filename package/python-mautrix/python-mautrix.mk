################################################################################
#
# mautrix
#
################################################################################

PYTHON_MAUTRIX_VERSION = 0.12.4
PYTHON_MAUTRIX_SOURCE = mautrix-$(PYTHON_MAUTRIX_VERSION).tar.gz
PYTHON_MAUTRIX_SITE = https://files.pythonhosted.org/packages/37/ee/317f92c042faa1176028239f31e6d9ab03aca7c0e7a7f5094a6570cb7a35
PYTHON_MAUTRIX_SETUP_TYPE = setuptools

$(eval $(python-package))
