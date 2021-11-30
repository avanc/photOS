################################################################################
#
# photoframe-matrix
#
################################################################################

define PHOTOFRAME_MATRIX_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(PHOTOFRAME_MATRIX_PKGDIR)/S82matrixclient $(TARGET_DIR)/etc/init.d/S82matrixclient
	$(INSTALL) -D -m 644 $(PHOTOFRAME_MATRIX_PKGDIR)/matrix_config.yml $(TARGET_DIR)/data/photoframe/conf/matrix_config.yml
endef

$(eval $(generic-package))
