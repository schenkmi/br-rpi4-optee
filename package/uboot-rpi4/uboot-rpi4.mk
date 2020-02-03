UBOOT_RPI4_VERSION = v2020.01
#UBOOT_RPI4_SITE = $(call github,u-boot,u-boot,u-boot-$(UBOOT_RPI4_VERSION))


#UBOOT_RPI4_SITE = $(call qstrip,"https://github.com/u-boot/u-boot")


UBOOT_RPI4_SOURCE = $(UBOOT_RPI4_VERSION).tar.gz

UBOOT_RPI4_SITE = https://github.com/u-boot/u-boot/archive



UBOOT_RPI4_INSTALL_TARGET = YES
UBOOT_RPI4_INSTALL_HOST = YES
UBOOT_RPI4_INSTALL_IMAGES = YES
UBOOT_RPI4_DEPENDENCIES = linux optee-os

UBOOT_EXT_DTB = $(BINARIES_DIR)/bcm2711-rpi-4-b.dtb

UBOOT_RPI4_BUILD_PARAMS = CROSS_COMPILE=$(TARGET_CROSS) ARCH=arm

UBOOT_RPI4_SIGNED_BUILD_PARAMS = CROSS_COMPILE=$(TARGET_CROSS) ARCH=arm \
	EXT_DTB=$(@D)/signed.dtb

UBOOT_RPI4_DEPENDENCIES += host-dtc

define UBOOT_RPI4_BUILD_CMDS
	cp $(UBOOT_RPI4_PKGDIR)/sources/head.S $(@D)/
	cp $(UBOOT_RPI4_PKGDIR)/sources/rpi4_fit.its $(@D)/
	$(TARGET_CROSS)as $(@D)/head.S -o $(@D)/head.o
	$(TARGET_CROSS)objcopy -O binary $(@D)/head.o $(@D)/head.bin
	$(MAKE) -C $(@D) $(UBOOT_RPI4_BUILD_PARAMS) rpi_4_defconfig
	$(MAKE) -C $(@D) $(UBOOT_RPI4_BUILD_PARAMS) tools
	$(@D)/tools/mkenvimage -s $(BR2_PACKAGE_UBOOT_RPI4_ENVIMAGE_SIZE) -o $(@D)/uboot-env.bin $(BR2_PACKAGE_UBOOT_RPI4_ENVIMAGE_SOURCE)
	mkdir -p $(@D)/keys
	if [ ! -f "$(@D)/keys/dev.key" ]; then openssl genrsa -F4 -out "$(@D)/keys/dev.key" 2048; fi
	if [ ! -f "$(@D)/keys/dev.crt" ]; then openssl req -batch -new -x509 -key "$(@D)/keys/dev.key" -out "$(@D)/keys/dev.crt"; fi
	cp $(UBOOT_EXT_DTB) $(@D)/signed.dtb
	cp $(UBOOT_EXT_DTB) $(@D)/
	cp $(UBOOT_EXT_DTB) $(@D)/bcm2711-rpi-4-b
	cp $(BINARIES_DIR)/optee.bin $(@D)/
	cp $(BINARIES_DIR)/Image $(@D)/
	$(@D)/tools/mkimage -f $(@D)/rpi4_fit.its -K $(@D)/signed.dtb -k $(@D)/keys -r $(@D)/image.fit
	$(@D)/tools/fit_check_sign -f $(@D)/image.fit -k $(@D)/signed.dtb
	$(MAKE) -C $(@D) $(UBOOT_RPI4_SIGNED_BUILD_PARAMS) all
	cat $(@D)/head.bin $(@D)/u-boot.bin > $(@D)/u-boot-rpi.bin
endef

define UBOOT_RPI4_INSTALL_IMAGES_CMDS
	$(INSTALL) -m 755 -D $(@D)/u-boot-rpi.bin $(BINARIES_DIR)/
	$(INSTALL) -m 755 -D $(@D)/uboot-env.bin $(BINARIES_DIR)/
	$(INSTALL) -m 755 -D $(@D)/image.fit $(BINARIES_DIR)/
endef

$(eval $(generic-package))
