#!/bin/bash
# Stuff for managing QEMU.

function runQEMU
{
	fileName="$1"
	
	# TODO Make this threadsafe.
	swapFile=~/chroots/build/swapdir/swap.img # By hard coding this, if another image is run concurrently, they will both want the same swap image, and that would be baaaaaaaaaaaaaad.
	
	qemu-system-arm \
		-kernel ~/chroots/build/pi-kernels/kernel-qemu-4.4.34-jessie \
		-cpu arm1176 \
		-m 256 \
		-serial stdio \
		-append "root=/dev/sda2 rootfstype=ext4 rw" \
		-drive format=raw,file="$fileName" \
		-drive format=raw,file="$swapFile" \
		-net nic \
		-net user,hostfwd=tcp::5022-:22 \
		-no-reboot \
		-machine versatileab
}
