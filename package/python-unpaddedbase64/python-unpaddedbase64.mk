################################################################################
#
# python-unpaddedbase64
#
################################################################################

PYTHON_UNPADDEDBASE64_VERSION = 2.1.0
PYTHON_UNPADDEDBASE64_SOURCE = unpaddedbase64-$(PYTHON_UNPADDEDBASE64_VERSION).tar.gz
PYTHON_UNPADDEDBASE64_SITE = https://files.pythonhosted.org/packages/4d/f8/114266b21a7a9e3d09b352bb63c9d61d918bb7aa35d08c722793bfbfd28f
PYTHON_UNPADDEDBASE64_SETUP_TYPE = setuptools
PYTHON_UNPADDEDBASE64_LICENSE = Apache-2.0
PYTHON_UNPADDEDBASE64_LICENSE_FILES = LICENSE

$(eval $(python-package))
