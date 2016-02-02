#!/bin/bash
#Define Paths
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dest=~/xda/GPE_M8_Kernel
mkdir -p $dest
date=$(date +%d-%m-%y)
export PATH=/home/tom/xda/kernel/toolchains/arm/linaro_5.2/bin:$PATH
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=arm-eabi-
export KBUILD_BUILD_USER=root

#Get Version Number
echo "Please enter version number: "
read version

#Ask user if they would like to clean
read -p "Would you like to clean (y/n)? " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
    make clean 
    make mrproper
    rm .config
    rm arch/arm/boot/dt.img
fi

#Set Local Version String
rm .version
VER="-~clumsy~_M8_$version"
DATE_START=$(date +"%s")


make m8_defconfig
str="CONFIG_LOCALVERSION=\"$VER\""
sed -i "45s/.*/$str/" .config
read -p "Would you like to see menu config (y/n)? " -n 1 -r
echo 
   
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
    make menuconfig
fi 

make -j4 
DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo
if (( $(($DIFF / 60)) == 0 )); then
echo " Build completed in $(($DIFF % 60)) seconds."
elif (( $(($DIFF / 60)) == 1 )); then
echo " Build completed in $(($DIFF / 60)) minute and $(($DIFF % 60)) seconds."
else
echo " Build completed in $(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds."
fi
echo " Finish time: $(date +"%r")"
echo

mkdir -p $dest/system/lib/modules/
find . -name '*ko' -exec cp '{}' $dest/system/lib/modules/ \;
cp arch/arm/boot/zImage $dest/.


echo "-> Done"

