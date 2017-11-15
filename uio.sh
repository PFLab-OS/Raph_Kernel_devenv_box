#!/bin/bash -x

sudo su -c "grep '^deb ' /etc/apt/sources.list | sed 's/^deb/deb-src/g' > /etc/apt/sources.list.d/deb-src.list"
sudo sed -i'~' -E "s@http://(..\.)?(archive|security)\.ubuntu\.com/ubuntu@http://linux.yz.yamagata-u.ac.jp/pub/linux/ubuntu-archive/@g" /etc/apt/sources.list
cd $HOME

sudo apt update -y
sudo apt install -y git g++ make autoconf emacs language-pack-ja-base language-pack-ja gdb silversearcher-ag

sudo apt install -y build-essential kernel-package libssl-dev linux-headers-$(uname -r)
apt source -y linux-source-4.4.0
# sudo apt build-dep linux-source-$(uname -r)
cd linux-4.4.0/
make oldconfig
make prepare
make scripts
cp -v /usr/src/linux-headers-$(uname -r)/Module.symvers .
cd drivers/uio/
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
sudo make -C /lib/modules/$(uname -r)/build M=$(pwd) modules_install
sudo depmod
sudo modprobe uio
sudo modprobe uio_pci_generic
cd ../../../
