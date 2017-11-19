#!/bin/bash
# Build a devuan chroot using debootstrap.

# Bare bones pre-requites
export now="`date +%Y-%m-%d--%H%M%S`"
export mountPoint="chroots/build/$now"
export imageHome="chroots/images"

if [ "$chrootLabel" == "" ]; then
	export image="$imageHome/$now.img"
else
	export image="$imageHome/$now-$chrootLabel.img"
fi
export blocks="2K"
export blockSize="1M"
export bareMinimumPackages="make,gcc,less,vim,netbase,wget,binutils,apt,apt-utils,nmon"

mkdir -p "$mountPoint" "$imageHome"


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
	for varName in image packages blocks blockSize;do
		echo "$varName "${!varName}
	done
}

function chrootPackages
{
	echo "$bareMinimumPackages,`echo $@ | sed 's/ /,/g'`"
}

function chrootGetImage
{
	echo "$image"
}

function chrootCreateBareImage
{
	echo "Create image."
	dd if=/dev/zero of="$image" bs="$blockSize" count=1 seek="$blocks" && \
	mkfs.ext4 "$image"

	return $?
}

function chrootMountImage
{
	echo "Mount"
	mount -o loop "$image" "$mountPoint"
	
	return $?
}

function chrootBuildContents
{
	echo "Build"
	debootstrap --no-check-gpg --include="$packages" --arch "armel" "jessie" "$mountPoint" "http://auto.mirror.devuan.org/merged/"

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
	gzip "$image"
}

function chrootBuildAll
{
	chrootCreateBareImage
	chrootMountImage
	chrootBuildContents
	chrootUmountImage
}

