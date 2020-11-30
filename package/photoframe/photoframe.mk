################################################################################
#
# photoframe
#
################################################################################

PHOTOFRAME_LICENSE = GPL-3.0+

define PHOTOFRAME_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(PHOTOFRAME_PKGDIR)/photoframe.sh $(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 0755 $(PHOTOFRAME_PKGDIR)/S80photoframe $(TARGET_DIR)/etc/init.d
	$(INSTALL) -D -m 0644 $(PHOTOFRAME_PKGDIR)/etc_photoframe/davfs2.conf $(TARGET_DIR)/etc/photoframe
	$(INSTALL) -D -m 0600 $(PHOTOFRAME_PKGDIR)/etc_photoframe/photoframe.conf $(TARGET_DIR)/etc/photoframe
	$(INSTALL) -D -m 0644 $(PHOTOFRAME_PKGDIR)/images/noimages.png $(TARGET_DIR)/usr/share/photoframe
endef


$(eval $(generic-package))
