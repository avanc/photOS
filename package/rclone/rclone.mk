################################################################################
#
# Rclone
#
################################################################################

RCLONE_VERSION = 1.57.0
RCLONE_SITE = https://downloads.rclone.org/v$(RCLONE_VERSION)/
RCLONE_SOURCE = rclone-v$(RCLONE_VERSION)-linux-arm.zip
RCLONE_LICENSE = MIT

define RCLONE_EXTRACT_CMDS
	$(UNZIP) -d $(@D) $(RCLONE_DL_DIR)/$(RCLONE_SOURCE)
	mv $(@D)/rclone-v$(RCLONE_VERSION)-linux-arm/* $(@D)
	$(RM) -r $(@D)/rclone-v$(RCLONE_VERSION)-linux-arm
endef

define RCLONE_BUILD_CMDS
endef

define RCLONE_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/rclone $(TARGET_DIR)/usr/bin/rclone
endef

$(eval $(generic-package))
