#!/bin/sh

# this bootstrap script runs initially as the 'pi' user 
# until we swap to 'basho' and remove 'pi' to tidy up.

# set some variables based on mac address
MAC_ADDRESS=`cat /sys/class/net/eth0/address`

case "$MAC_ADDRESS" in
  "b8:27:eb:fc:c5:10")
    export NEW_HOSTNAME="utility"
    ;;
  "b8:27:eb:a6:0d:2f")
    export NEW_HOSTNAME="riak1"
    ;;
  "b8:27:eb:db:53:2e")
    export NEW_HOSTNAME="riak2"
    ;;
  "b8:27:eb:9e:ea:52")
    export NEW_HOSTNAME="riak3"
    ;;
  "b8:27:eb:d3:24:30")
    export NEW_HOSTNAME="riak4"
    ;;
  "b8:27:eb:e4:bf:27")
    export NEW_HOSTNAME="riak5"
    ;;
  *)
    ;;
esac

# expand filesystem
sudo raspi-config --expand-rootfs

# overclock pi
echo "\
arm_freq=1000
core_freq=500
sdram_freq=500
over_voltage=2
gpu_mem=16" | sudo tee -a /boot/config.txt

# set hostname
echo $NEW_HOSTNAME | sudo tee /etc/hostname
sudo sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts

# add other node IPs
echo -e "\
192.168.0.110\tutility
192.168.0.111\triak1
192.168.0.112\triak2
192.168.0.113\triak3
192.168.0.114\triak4
192.168.0.115\triak5\
" | sudo tee -a /etc/hosts

# install newer versions of gcc and g++
sudo sed -i 's/wheezy/jessie/g' /etc/apt/sources.list
sudo apt-get update --fix-missing
sudo apt-get install gcc=4:4.9.2-2 g++=4:4.9.2-2 --yes
sudo sed -i 's/jessie/wheezy/g' /etc/apt/sources.list

# remove pistore from skel
sudo rm /etc/skel/pistore.desktop

# add basho user with sudo rights
sudo useradd basho -g sudo -m

# update password for basho
sudo passwd basho <<EOF
demo-cluster
demo-cluster
EOF

# add basho user to sudoers file
echo "basho ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers