#!/bin/bash

mkdir build-linux
cd build-linux

if [ $? -gt 0 ]; then
    echo !!! Error: "build-linux" exists on the current directory. Please remove/rename it and retry this script. !!!
    exit
fi

sudo su -c "grep '^deb ' /etc/apt/sources.list | sed 's/^deb/deb-src/g' > /etc/apt/sources.list.d/deb-src.list"
sudo sed -i'~' -E "s@http://(..\.)?(archive|security)\.ubuntu\.com/ubuntu@http://linux.yz.yamagata-u.ac.jp/pub/linux/ubuntu-archive/@g" /etc/apt/sources.list

sudo apt update -qq

sudo apt-get build-dep -qq linux-image-$(uname -r)
apt-get source -y -qq linux-image-$(uname -r)
cd linux-*
yes "" | make oldconfig
make prepare
make scripts
cp -v /usr/src/linux-headers-$(uname -r)/Module.symvers .
cd drivers/uio/
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
sudo make -C /lib/modules/$(uname -r)/build M=$(pwd) modules_install
sudo depmod
sudo modprobe uio
sudo modprobe uio_pci_generic
cd ../../../../
