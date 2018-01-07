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

function chrootImage
{
	if [ "$1" != "" ]; then
		export chrootImageName="$1"
	else
		export chrootImageName="`ls -1 ~/chroots/images/ | sort -u | tail -n1`"
	fi
	
	export chrootImage=~/chroots/images/$chrootImageName
}

function chrootRun
{
	case $arch in
		armv7hl)
			log "Run using scratchbox ("$buildName"): $@"
			sb2 -t "$buildName" -R "$@"
		;;
		*)
			log "Run using chroot: $@"
			chroot "$mountPoint" "$@"
		;;
	esac
	
	return $?
}

function chrootMountImage
{
	doing "Mount"
	mount -o loop "$chrootImage" "$mountPoint"
	
	return $?
}

function chrootUmountImage
{
	doing "Unmount"
	umount "$mountPoint"

	return $?
}

function chrootCompress
{
	doing "Compress"
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
	doing "Create chrootImage."
	dd if=/dev/zero of="$chrootImage" bs="$blockSize" count=1 seek="$blocks" && \
	mkfs.ext4 "$chrootImage"

	return $?
}

function getNow
{
	date +%Y-%m-%d--%H%M%S
}

export now="`getNow`"
chrootUseBuildDir $now
export chrootHome=~/chroots
export chrootImageHome=$chrootHome/images
export blocks="4K"
export blockSize="1M"
