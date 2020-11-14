################################################################################
#
# photoframe
#
################################################################################

PHOTOFRAME_VERSION = 0.0.1
PHOTOFRAME_LICENSE = GPL-3.0+
#PHOTOFRAME_SITE = hello

define PHOTOFRAME_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(LIBFOO_PKGDIR)/photoframe.sh $(TARGET_DIR)/bin
	$(INSTALL) -D -m 0755 $(LIBFOO_PKGDIR)/S51photoframe $(TARGET_DIR)/etc/init.d
	$(INSTALL) -D -m 0700 $(LIBFOO_PKGDIR)/etc_photoframe $(TARGET_DIR)/etc
endef


$(eval $(autotools-package))
