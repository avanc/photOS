################################################################################
#
# thingos-webui
#
################################################################################

THINGOS_WEBUI_VERSION = 3f96e80
THINGOS_WEBUI_SITE = https://github.com/avanc/thingos-webui.git
THINGOS_WEBUI_SITE_METHOD = git

THINGOS_WEBUI_LICENSE = GPL-2.0
THINGOS_WEBUI_LICENSE_FILES = LICENSE
THINGOS_WEBUI_SETUP_TYPE = setuptools

define THINGOS_WEBUI_INSTALL_TARGET_CMDS
    # setuptools install
    (cd $($(PKG)_BUILDDIR)/; \
        $($(PKG)_BASE_ENV) $($(PKG)_ENV) \
        $($(PKG)_PYTHON_INTERPRETER) setup.py install \
        $($(PKG)_BASE_INSTALL_TARGET_OPTS) \
        $($(PKG)_INSTALL_TARGET_OPTS))

	$(INSTALL) -D -m 0755 $(THINGOS_WEBUI_PKGDIR)/S81webui $(TARGET_DIR)/etc/init.d/S81webui
endef

$(eval $(python-package))
