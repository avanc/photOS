################################################################################
#
# photoframe
#
################################################################################

PHOTOFRAME_LICENSE = GPL-3.0+

define PHOTOFRAME_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(PHOTOFRAME_PKGDIR)/photoframe.sh $(TARGET_DIR)/usr/bin/photoframe.sh
    $(INSTALL) -D -m 0755 $(PHOTOFRAME_PKGDIR)/S80photoframe $(TARGET_DIR)/etc/init.d/S80photoframe
	$(INSTALL) -D -m 0755 $(PHOTOFRAME_PKGDIR)/S79photoframe_upgrade $(TARGET_DIR)/etc/init.d/S79photoframe_upgrade
	$(INSTALL) -D -m 0644 $(PHOTOFRAME_PKGDIR)/etc_photoframe/davfs2.conf $(TARGET_DIR)/etc/photoframe/davfs2.conf
	$(INSTALL) -D -m 0644 $(PHOTOFRAME_PKGDIR)/images/noimages.png $(TARGET_DIR)/usr/share/photoframe/noimages.png

    $(INSTALL) -D -m 0755 $(PHOTOFRAME_PKGDIR)/pir/motion_detector.py $(TARGET_DIR)/usr/bin/motion_detector.py
    $(INSTALL) -D -m 0755 $(PHOTOFRAME_PKGDIR)/pir/S81motiondetector $(TARGET_DIR)/etc/init.d/S81motiondetector
endef


$(eval $(generic-package))
