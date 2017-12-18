#!/bin/bash
# General stuff for working with a chroot.

function chrootUseBuildDir
{
	if [ "$1" != "" ]; then
		export buildName="$1"
	else
		export buildName="`ls -1 ~/chroots/build/ | sort -u | tail -n1`"
	fi
	
	export mountPoint=~/chroots/build/$buildName
}

function chrootRun
{
	case $arch in
		arm*)
			echo "Run using scratchbox ("$buildName"): $@"
			sb2 -t "$buildName" -R "$@"
		;;
		*)
			echo "Run using chroot: $@"
			chroot "$mountPoint" "$@"
		;;
	esac
	
	return $?
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
	mount -t proc none $mountPoint/proc
	for fs in /dev /sys; do
		mount --rbind $fs $mountPoint$fs
	done
	
	mkdir -p $mountPoint/run/shm
}

function chrootUnMountExtras
{
	for fs in /dev /proc /sys; do
		umount $mountPoint$fs
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
export chrootHome=~/chroots
export chrootImageHome=$chrootHome/images
export blocks="4K"
export blockSize="1M"
