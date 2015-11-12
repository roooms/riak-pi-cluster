#!/bin/bash

# Unmount the all SD Card volumes (normally disk1)
diskutil unmountDisk /dev/disk1
# Copy the Raspbian image to the raw disk (wheezy should take approx 300 seconds)
#sudo dd bs=1m if=~/Documents/2015-05-05-raspbian-wheezy.img of=/dev/rdisk1
sudo dd bs=1m if=~/Documents/2015-09-24-raspbian-jessie.img of=/dev/rdisk1
# Eject the SD Card
diskutil eject /dev/disk1
