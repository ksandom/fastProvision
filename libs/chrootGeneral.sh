#!/bin/bash
# General stuff for working with a chroot.

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
	for fs in /dev /proc /sys; do
		mount -o bind $fs $mountPoint$fs
	done
	
	mount -o rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 devpts $mountPoint/dev/pts -t devpts
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


export now="`date +%Y-%m-%d--%H%M%S`"
chrootUseBuildDir $now
export chrootImageHome=~/chroots/images
export blocks="4K"
export blockSize="1M"
