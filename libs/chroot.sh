#!/bin/bash
# Build a devuan chroot using debootstrap.

# Bare bones pre-requites
export now="`date +%Y-%m-%d--%H%M%S`"
export mountPoint="~/chroots/build/$now"
export chrootImageHome="~/chroots/chrootImages"

if [ "$chrootLabel" == "" ]; then
	export chrootImage="$chrootImageHome/$now.img"
else
	export chrootImage="$chrootImageHome/$now-$chrootLabel-$arch.img"
fi
export blocks="2K"
export blockSize="1M"
export bareMinimumPackages="make,gcc,less,vim,netbase,wget,binutils,apt,apt-utils,nmon"
export arch="armhf"

mkdir -p "$mountPoint" "$chrootImageHome"


function chrootVars
{
	echo "Chroot vars:"
	chrootGetVars | chrootPrettyTable
	echo
}

function chrootPrettyTable
{
	column -s\	 -t | while read in;do echo "  $in";done
}

function chrootGetVars
{
	for varName in chrootImage packages arch blocks blockSize;do
		echo "$varName "${!varName}
	done
	exit 1
}

function chrootPackages
{
	echo "$bareMinimumPackages,`echo $@ | sed 's/ /,/g'`"
}

function chrootGetImage
{
	echo "$chrootImage"
}

function chrootCreateBareImage
{
	echo "Create chrootImage."
	dd if=/dev/zero of="$chrootImage" bs="$blockSize" count=1 seek="$blocks" && \
	mkfs.ext4 "$chrootImage"

	return $?
}

function chrootMountImage
{
	echo "Mount"
	mount -o loop "$chrootImage" "$mountPoint"
	
	return $?
}

function chrootBuildContents
{
	echo "Build"
	debootstrap --no-check-gpg --include="$packages" --arch "$arch" "jessie" "$mountPoint" "http://auto.mirror.devuan.org/merged/"

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
	gzip "$chrootImage"
}

function chrootBuildAll
{
	chrootCreateBareImage
	sleep 2
	chrootMountImage
	sleep 2
	chrootBuildContents
	sleep 2
	chrootUmountImage
}


