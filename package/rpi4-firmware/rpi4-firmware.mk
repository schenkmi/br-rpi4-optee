RPI4_FIRMWARE_VERSION = 1.20200114
RPI4_FIRMWARE_SITE = $(call github,raspberrypi,firmware,$(RPI4_FIRMWARE_VERSION))
RPI4_FIRMWARE_INSTALL_IMAGES = YES

define RPI4_FIRMWARE_INSTALL_IMAGES_CMDS
	cp -r $(@D)/boot $(BINARIES_DIR)/rpi-firmware
endef

$(eval $(generic-package))
