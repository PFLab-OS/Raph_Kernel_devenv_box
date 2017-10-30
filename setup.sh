#!/bin/bash -x

sudo su -c "grep '^deb ' /etc/apt/sources.list | sed 's/^deb/deb-src/g' > /etc/apt/sources.list.d/deb-src.list"
sudo sed -i'~' -E "s@http://(..\.)?(archive|security)\.ubuntu\.com/ubuntu@http://linux.yz.yamagata-u.ac.jp/pub/linux/ubuntu-archive/@g" /etc/apt/sources.list
cd $HOME

sudo apt update -y
sudo apt install -y gdebi git g++ make autoconf bison flex parted emacs language-pack-ja-base language-pack-ja kpartx gdb bridge-utils libyaml-dev silversearcher-ag ccache doxygen graphviz
# sudo apt install -y grub-efi
sudo apt install -y gdisk dosfstools
sudo update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

echo 'export USE_CCACHE=1' >> ~/.bashrc
echo 'export CCACHE_DIR=~/.ccache' >> ~/.bashrc
echo 'export PATH="/usr/lib/ccache:$PATH"' >> ~/.bashrc

# install qemu
sudo apt install -y libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev
wget http://download.qemu-project.org/qemu-2.9.0.tar.xz
tar xvJf qemu-2.9.0.tar.xz
mkdir build-qemu
cd build-qemu
../qemu-2.9.0/configure --target-list=x86_64-softmmu --disable-kvm --enable-debug
make -j2
sudo make install
cd ..

# install OVMF
sudo apt install -y build-essential uuid-dev nasm iasl
git clone -b UDK2017 https://github.com/tianocore/edk2 --depth=1
cd edk2
make -C BaseTools
. ./edksetup.sh
build -a X64 -t GCC5 -p OvmfPkg/OvmfPkgX64.dsc
mkdir ~/edk2-UDK2017
cp Build/OvmfX64/DEBUG_GCC5/FV/*.fd ~/edk2-UDK2017
cd ..

# make & install musl with CFLAGS="-fpie -fPIE"
git clone -b v0.9.15 git://git.musl-libc.org/musl --depth=1
cd musl
export CFLAGS="-fpie -fPIE"
./configure --prefix=/usr/local/musl --exec-prefix=/usr/local
unset CFLAGS
make -j2
sudo make install
cd ..

# install grub
sudo apt install -y libdevmapper-dev
wget http://alpha.gnu.org/gnu/grub/grub-2.02~beta3.tar.gz
tar zxvf grub-2.02~beta3.tar.gz
cd grub-2.02~beta3
./autogen.sh
./configure --target=i386 --with-platform=pc
make
sudo make install
make clean
./configure --target=x86_64 --with-platform=efi
make
sudo make install
cd ..

# install iPXE
sudo apt install -y build-essential binutils-dev zlib1g-dev libiberty-dev liblzma-dev
git clone http://git.ipxe.org/ipxe.git --depth=1
cd ipxe/src
# make bin-x86_64-pcbios/ipxe.usb
cd ../../

# install rust
#(curl -sSf https://static.rust-lang.org/rustup.sh | sh) || return 0
#echo "export PATH=\$PATH:~/.cargo/bin\n" >> /home/vagrant/.bashrc
#cargo install rustfmt --verbose

# setup bridge initialize script
sudo sed -i -e 's/exit 0//g' /etc/rc.local
sudo sh -c 'echo "ifconfig enp0s3 down" >> /etc/rc.local'
sudo sh -c 'echo "ifconfig enp0s3 up" >> /etc/rc.local'
sudo sh -c 'echo "ip addr flush dev enp0s3" >> /etc/rc.local'
sudo sh -c 'echo "brctl addbr br0" >> /etc/rc.local'
sudo sh -c 'echo "brctl stp br0 off" >> /etc/rc.local'
sudo sh -c 'echo "brctl setfd br0 0" >> /etc/rc.local'
sudo sh -c 'echo "brctl addif br0 enp0s3" >> /etc/rc.local'
sudo sh -c 'echo "ifconfig br0 up" >> /etc/rc.local'
sudo sh -c 'echo "dhclient br0" >> /etc/rc.local'
sudo sh -c 'echo "exit 0" >> /etc/rc.local'
sudo /etc/rc.local

sudo mkdir /usr/local/etc/qemu
sudo sh -c 'echo "allow br0" > /usr/local/etc/qemu/bridge.conf'

sudo mkdir "/mnt/Raph_Kernel"
sudo mkdir "/mnt/efi"

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


sudo sed -i -e 's/timeout=30/timeout=3/g' /boot/grub/grub.cfg

sudo sh -c 'date > /etc/bootstrapped'


# clean up
sudo rm /var/log/*
dd if=/dev/zero of=zero bs=4k || :
rm zero

echo "setup done!"
