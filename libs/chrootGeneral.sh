#!/bin/bash
# General stuff for working with a chroot.

export now="`date +%Y-%m-%d--%H%M%S`"
chrootUseBuildDir $now
export chrootImageHome=~/chroots/images
export blocks="4K"
export blockSize="1M"

function chrootUseBuildDir
{
	if [ "$1" != "" ]; then
		buildName="$1"
	else
		buildName="`ls -1 ~/chroots/build/ | sort -u | tail -n1`"
	fi
	
	export mountPoint=~/chroots/build/$buildName
}

function chrootRun
{
	chroot "$mountPoint" "$@"
}

function chrootMountImage
{
	echo "Mount"
	mount -o loop "$chrootImage" "$mountPoint"
	
	return $?
}

function chrootUmountImage
{
	echo "Unmount"
	umount "$mountPoint"

	return $?
}

function chrootCompress
{
	echo "Compress"
	gzip "$chrootImage"
}

function chrootMountExtras
{
	for fs in /dev /dev/pts /proc /sys; do
		mount -o bind $fs $mountPoint$fs
	done
}

function chrootUnMountExtras
{
	for fs in /dev/pts /dev /proc /sys; do
		mount -o bind $fs $mountPoint$fs
	done
}

function chrootCreateBareImage
{
	echo "Create chrootImage."
	dd if=/dev/zero of="$chrootImage" bs="$blockSize" count=1 seek="$blocks" && \
	mkfs.ext4 "$chrootImage"

	return $?
}


