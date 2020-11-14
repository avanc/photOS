################################################################################
#
# photoframe
#
################################################################################

PHOTOFRAME_LICENSE = GPL-3.0+

define PHOTOFRAME_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(PHOTOFRAME_PKGDIR)/photoframe.sh $(TARGET_DIR)/bin
	$(INSTALL) -D -m 0755 $(PHOTOFRAME_PKGDIR)/S51photoframe $(TARGET_DIR)/etc/init.d
	$(INSTALL) -D -m 0644 $(PHOTOFRAME_PKGDIR)/etc_photoframe/davfs2.conf $(TARGET_DIR)/etc
	$(INSTALL) -D -m 0600 $(PHOTOFRAME_PKGDIR)/etc_photoframe/photoframe.conf $(TARGET_DIR)/etc
endef


$(eval $(generic-package))
