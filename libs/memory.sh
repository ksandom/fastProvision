#!/bin/bash
# Checks memory, and if there isn't enough, configure zswap
# Derived from: https://gist.github.com/sultanqasim/79799883c6b81c710e36a38008dfa374

# Tuneables for when to automatically apply it.
zswapMemoryThresholdKB="1000000"
zswapSwapThresholdKB="1000000"

# Tuneables for what to do when applying it.
zswapStreams="3"
zswapCompression="lz4"
zswapMemoryLimit="768M"
zswapDiskSize="1536M"
zswapDevice="zram0"


function zswapDetect
{
	memTotal=`grep MemTotal /proc/meminfo | awk '{print $2}'`
	
	if [ "$memTotal" -lt "$zswapMemoryThresholdKB" ]; then
		swapTotal=`grep SwapTotal /proc/meminfo | awk '{print $2}'`
		
		if [ "$swapTotal" -lt "$zswapMemoryThresholdKB" ]; then
			doing "zswap: Memory ($memTotal) < threshold ($zswapMemoryThresholdKB) and swap ($swapTotal) < threshold ($zswapMemoryThresholdKB). Enabling zswap."
			zswapTurnOn
		else
			logQuietly "zswap: Swap ($swapTotal) > threshold ($zswapMemoryThresholdKB). No action necessary. Note that if this is traditional swap, it may be slow. If so you could enable zswap instead by doing \`./usefulStuff/zswap.sh\`."
		fi
	fi
}

function zswapTurnOn
{
	swapoff -a

	modprobe zram
	echo "$zswapStreams" >/sys/devices/virtual/block/$zswapDevice/max_comp_streams
	echo "$zswapCompression" >/sys/devices/virtual/block/$zswapDevice/comp_algorithm
	echo "$zswapMemoryLimit" >/sys/devices/virtual/block/$zswapDevice/mem_limit
	echo "$zswapDiskSize" >/sys/devices/virtual/block/$zswapDevice/disksize
	mkswap "/dev/$zswapDevice"
	swapon -p 0 "/dev/$zswapDevice"
	sysctl vm.swappiness=70
}


# TODO This caters to all current situations, but in the future it may become a PITA. (Eg if we want to override the default settings.) At that point it will be time to refactor how this is triggered.
zswapDetect
