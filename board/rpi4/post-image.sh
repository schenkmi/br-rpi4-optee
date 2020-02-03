#!/bin/sh

ITS_FILE="${BR2_EXTERNAL_RPI4_OPTEE_PATH}/board/rpi4/rpi4_fit.its"
CONFIG_FILE="${BR2_EXTERNAL_RPI4_OPTEE_PATH}/board/rpi4/config.txt"

cd ${BINARIES_DIR}
echo $(pwd)

mkdir -p boot
cp image.fit boot/
cp u-boot-rpi.bin boot/
cp uboot-env.bin boot/
cp rpi-firmware/COPYING.linux boot/
cp rpi-firmware/LICENCE.broadcom boot/
cp rpi-firmware/bootcode.bin boot/
cp rpi-firmware/fixup4.dat boot/
cp rpi-firmware/fixup4cd.dat boot/
cp rpi-firmware/fixup4db.dat boot/
cp rpi-firmware/fixup4x.dat boot/
cp rpi-firmware/start4.elf boot/
cp rpi-firmware/start4cd.elf boot/
cp rpi-firmware/start4db.elf boot/
cp rpi-firmware/start4x.elf boot/
cp ${CONFIG_FILE} boot/

cd boot
tar -cvf ../bootfs.tar .

GENIMAGE_CFG="${BR2_EXTERNAL_RPI4_OPTEE_PATH}/board/rpi4/genimage-raspberrypi4-64.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?

