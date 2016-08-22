#!/bin/bash

# Custom Kernel build script

# Constants
CPU_THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
green='\033[01;32m'
default='\033[0m'

# Resources
ANDROID_DIR=/home/guneetatwal/android
KERNEL_DIR=$PWD
IMAGE=$KERNEL_DIR/arch/arm64/boot/Image
#IMAGE=$KERNEL_DIR/arch/arm/boot/zImage for 32 bit architecture
DTBTOOL=$KERNEL_DIR/scripts/dtbTool
TOOLCHAIN=$ANDROID_DIR/toolchain/aarch64-linux-android-4.9/bin

#Paths
OUT_DIR=$KERNEL_DIR/out
OUT_ZIP=$KERNEL_DIR/Blaze-Releases
MODULE_DIR=$OUT_DIR/system/lib/modules
NEW_OUT=$OUT_DIR/tools

# Kernel Version Info
BASE="-Blaze™Kernel-"
CUR_VER="1"
BLAZE_VER="$BASE$CUR_VER"
 

# Variables

DEFCONFIG="blaze_defconfig"
export LOCALVERSION=~`echo $BLAZE_VER`
export CROSS_COMPILE=$TOOLCHAIN/aarch64-linux-android-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="GuneetAtwal"
export KBUILD_BUILD_HOST="BeastPC"

function make_blaze {
		echo -e "$green***********************************************"
		echo "                  Compiling $BLAZE_VER	              "
		echo -e "***********************************************$default"
		echo
		make $DEFCONFIG
		make $THREAD
		rm -rf $NEWOUT/Image
		cp -vr $IMAGE $NEW_OUT
		make_dtb
		strip_modules
		make_zip
		}

function make_dtb {
		rm -rf $NEWOUT/dt.img
		$DTBTOOL -v -s 2048 -o $NEW_OUT -p scripts/dtc/ arch/arm/boot/dts/
		}

function make_zip {
		cd $OUT_DIR
		zip -r9 `echo $BLAZE_VER`.zip *
		mv  `echo $BLAZE_VER`.zip $OUT_ZIP
		cd $KERNEL_DIR 
		}

BUILD_START=$(date +"%s")
while read -p "Do you want to build kernel (y/n)? " choice
do
case "$choice" in
	y|Y)
		make_blaze
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Are you drunk???"
		echo
		;;
esac
done
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$green Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$default"
