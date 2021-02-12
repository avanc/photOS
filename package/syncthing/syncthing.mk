################################################################################
#
# syncthing
#
################################################################################

SYNCTHING_VERSION = 1.13.1
SYNCTHING_SITE = https://github.com/syncthing/syncthing/archive
SYNCTHING_SOURCE = v$(SYNCTHING_VERSION).tar.gz

SYNCTHING_LICENSE = Mozilla-Public-License-2.0
SYNCTHING_LICENSE_FILES = LICENSE

$(eval $(golang-package))
