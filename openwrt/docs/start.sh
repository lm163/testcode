#!/bin/sh
IMAGE=openwrt-armvirt-32-zImage
FILESYS=openwrt-armvirt-32-root.ext4
LAN=owrttap0
# create tap interface which will be connected to OpenWrt LAN NIC
ip tuntap add mode tap $LAN
ip link set dev $LAN up
# configure interface with static ip to avoid overlapping routes                         
ip addr add 192.168.1.10/24 dev $LAN
qemu-system-arm \
    -device virtio-net-pci,netdev=lan \
    -netdev tap,id=lan,ifname=$LAN,script=no,downscript=no \
    -device virtio-net-pci,netdev=wan \
    -netdev user,id=wan \
    -M virt -nographic -m 256 -kernel $IMAGE \
    -drive file=$FILESYS,format=raw,if=virtio -append 'root=/dev/vda rootwait'
# cleanup. delete tap interface created earlier
ip addr flush dev $LAN
ip link set dev $LAN down
ip tuntap del mode tap dev $LAN


