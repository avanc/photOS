################################################################################
#
# python-olm
#
################################################################################

PYTHON_OLM_VERSION = 3.1.3
PYTHON_OLM_SITE = https://files.pythonhosted.org/packages/d4/a4/1face47e65118d7c52726dfa305410a96bc4a0c6f3f99c90bc7104aebf21
PYTHON_OLM_SETUP_TYPE = setuptools
PYTHON_OLM_LICENSE = Apache 2.0
PYTHON_OLM_DEPENDENCIES = host-python-cffi


$(eval $(python-package))
