ARM_TF_VERSION = 989429e8726e55bac78292ead4400649350c4565
#ARM_TF_SITE = https://git.trustedfirmware.org/TF-A/trusted-firmware-a.git

#ARM_TF_SITE = $(BR2_PACKAGE_ARM_TF_SITE)







ARM_TF_SITE = $(call qstrip,$(BR2_PACKAGE_ARM_TF_SITE))
ARM_TF_SITE_METHOD = git
BR_NO_CHECK_HASH_FOR += $(ARM_TF_SOURCE)




ARM_TF_INSTALL_IMAGES = YES
ARM_TF_DEPENDENCIES = optee-os

define ARM_TF_BUILD_CMDS
	$(MAKE) -C $(@D) \
	BL32=$(BINARIES_DIR)/tee.bin \
	DEBUG=1 \
	V=0 \
	CRASH_REPORTING=1 \
	LOG_LEVEL=50 \
	PLAT=$(BR2_TARGET_OPTEE_OS_PLATFORM) \
	SPD=opteed \
	CROSS_COMPILE=$(TARGET_CROSS)
endef

ARM_TF_IMAGE_PATH = $(@D)/build/$(BR2_TARGET_OPTEE_OS_PLATFORM)/debug/

define ARM_TF_INSTALL_IMAGES_CMDS
	dd if=/dev/zero of=padding bs=1c count=131072
	cat $(ARM_TF_IMAGE_PATH)/bl31.bin padding > $(ARM_TF_IMAGE_PATH)/arm-tf.tmp.bin
	dd if=$(ARM_TF_IMAGE_PATH)/arm-tf.tmp.bin of=$(ARM_TF_IMAGE_PATH)/arm-tf.out.bin bs=1c count=131072
	cat $(ARM_TF_IMAGE_PATH)/arm-tf.out.bin $(BINARIES_DIR)/tee-pager_v2.bin > $(ARM_TF_IMAGE_PATH)/optee.bin
	$(INSTALL) -m 755 -D $(ARM_TF_IMAGE_PATH)/optee.bin $(BINARIES_DIR)/optee.bin
endef

$(eval $(generic-package))
