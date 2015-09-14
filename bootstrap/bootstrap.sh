#!/bin/sh

# this bootstrap script runs initially as the 'pi' user 
# until we swap to 'basho' and remove 'pi' to tidy up.

# set some variables based on mac address
export MAC_ADDRESS=`cat /sys/class/net/eth0/address`

case "$MAC_ADDRESS" in
  "b8:27:eb:fc:c5:10")
    export NEW_HOSTNAME="utility.pi"
    ;;
  "b8:27:eb:a6:0d:2f")
    export NEW_HOSTNAME="riak1.pi"
    ;;
  "b8:27:eb:db:53:2e")
    export NEW_HOSTNAME="riak2.pi"
    ;;
  "b8:27:eb:9e:ea:52")
    export NEW_HOSTNAME="riak3.pi"
    ;;
  "b8:27:eb:d3:24:30")
    export NEW_HOSTNAME="riak4.pi"
    ;;
  "b8:27:eb:e4:bf:27")
    export NEW_HOSTNAME="riak5.pi"
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
192.168.0.110\tutility utility.pi
192.168.0.111\triak1 riak1.pi
192.168.0.112\triak2 riak2.pi
192.168.0.113\triak3 riak3.pi
192.168.0.114\triak4 riak4.pi
192.168.0.115\triak5 riak5.pi\
" | sudo tee -a /etc/hosts

# install newer versions of gcc and g++
sudo sed -i 's/wheezy/jessie/g' /etc/apt/sources.list
sudo apt-get update --fix-missing
sudo apt-get install gcc=4:4.9.2-2 g++=4:4.9.2-2 --yes
sudo sed -i 's/jessie/wheezy/g' /etc/apt/sources.list

# install some commonly used packages
sudo apt-get update --fix-missing
sudo apt-get install vim git --yes

# set ulimits
sudo sh -c 'echo \
"* soft nofile 131072
* hard nofile 131072
root soft nofile 131072
root hard nofile 131072" \
>> /etc/security/limits.conf'

sudo sh -c 'echo \
"session    required    pam_limits.so" \
>> /etc/pam.d/common-session'

sudo sh -c 'echo \
"session    required    pam_limits.so" \
>> /etc/pam.d/common-session-noninteractive'

# set these values in sysctl.conf
sudo sh -c 'echo \
"vm.swappiness=0
net.core.wmem_default=8388608
net.core.rmem_default=8388608
net.core.wmem_max=8388608
net.core.rmem_max=8388608
net.core.netdev_max_backlog=10000
net.core.somaxconn=4000
net.ipv4.tcp_max_syn_backlog=40000
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_tw_reuse=1
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_mem  = 134217728 134217728 134217728
net.ipv4.tcp_rmem = 4096 277750 134217728
net.ipv4.tcp_wmem = 4096 277750 134217728
net.core.netdev_max_backlog = 300000" \
>> /etc/sysctl.conf'

# make changes effective
sudo sysctl -p

# vim syntax highlighting for easy 
# app.config and vm.args review
sudo sh -c 'echo \
"syntax on
filetype on
au BufNewFile,BufRead app.config set filetype=erlang
au BufNewFile,BufRead vm.args set filetype=sh" \
>> ~/.vimrc'

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
