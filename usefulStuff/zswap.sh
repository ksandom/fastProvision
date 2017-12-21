#!/bin/bash

# From: https://gist.github.com/sultanqasim/79799883c6b81c710e36a38008dfa374

# Raspberry Pi ZRAM script
# Tuned for quad core, 1 GB RAM models
# put me in /etc/init.d/zram.sh and make me executable
# then run "sudo update-rc.d zram.sh defaults"

swapoff -a

modprobe zram
echo 3 >/sys/devices/virtual/block/zram0/max_comp_streams
echo lz4 >/sys/devices/virtual/block/zram0/comp_algorithm
echo 768M >/sys/devices/virtual/block/zram0/mem_limit
echo 1536M >/sys/devices/virtual/block/zram0/disksize
mkswap /dev/zram0
swapon -p 0 /dev/zram0
sysctl vm.swappiness=70

