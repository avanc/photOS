################################################################################
#
# photoframe-matrix
#
################################################################################

define PHOTOFRAME_MATRIX_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(PHOTOFRAME_MATRIX_PKGDIR)/S82matrixclient $(TARGET_DIR)/etc/init.d/S82matrixclient
	$(INSTALL) -D -m 644 $(PHOTOFRAME_MATRIX_PKGDIR)/matrix_config_example.yml $(TARGET_DIR)/etc/photoframe/matrix_config_example.yml
endef

$(eval $(generic-package))
