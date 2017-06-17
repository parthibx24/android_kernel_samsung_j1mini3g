#!/bin/bash
##
#  Copyright (C) 2016, Samsung Electronics, Co., Ltd.
#  Written by System S/W Group, S/W Platform R&D Team,
#  Mobile Communication Division.
##

set -e -o pipefail

export CROSS_COMPILE=../PLATFORM/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-
export ARCH=arm

PLATFORM=sc8830
DEFCONFIG=j1mini3g-dt_defconfig

KERNEL_PATH=$(pwd)
MODULE_PATH=${KERNEL_PATH}/modules
EXTERNAL_MODULE_PATH=${KERNEL_PATH}/external_modules

JOBS=`grep processor /proc/cpuinfo | wc -l`

function build_kernel() {
	make ${DEFCONFIG}
	make -j${JOBS}
	make modules
	make dtbs
	make -C ${EXTERNAL_MODULE_PATH}/wifi_module KDIR=${KERNEL_PATH}
	make -C ${EXTERNAL_MODULE_PATH}/mali_module MALI_PLATFORM=${PLATFORM} KDIR=${KERNEL_PATH}

	[ -d ${MODULE_PATH} ] && rm -rf ${MODULE_PATH}
	mkdir -p ${MODULE_PATH}

	find ${KERNEL_PATH}/drivers -name "*.ko" -exec cp -f {} ${MODULE_PATH} \;
	find ${EXTERNAL_MODULE_PATH} -name "*.ko" -exec cp -f {} ${MODULE_PATH} \;
}

function clean() {
	[ -d ${MODULE_PATH} ] && rm -rf ${MODULE_PATH}
	make distclean
}

function main() {
	[ "${1}" = "Clean" ] && clean || build_kernel
}

main $@
