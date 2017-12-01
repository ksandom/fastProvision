#!/bin/bash
# Build a devuan chroot using debootstrap.

# Defaults
export chrootMirror="http://auto.mirror.devuan.org/merged/"
export chrootRelease="jessie"
export arch="armhf"
export bareMinimumPackages="make,gcc,less,vim,netbase,wget,binutils,apt,apt-utils,nmon,aptitude,tasksel,curl"


function chrootPrerequisites
{
	if [ "$chrootLabel" == "" ]; then
		export chrootImage="$chrootImageHome/$now.img"
	else
		export chrootImage="$chrootImageHome/$now-$chrootLabel-$chrootRelease-$arch.img"
	fi
	
	mkdir -p "$mountPoint" "$chrootImageHome"
}

function chrootVars
{
	echo "Chroot vars:"
	chrootGetVars  #  | chrootPrettyTable
	echo
}

function chrootPrettyTable
{
	column -s\	 -t | while read in;do echo "  $in";done
}

function chrootGetVars
{
	for varName in chrootImage packages arch blocks blockSize;do
		echo "$varName    "${!varName}
	done
}

function chrootPackages
{
	chrootPrerequisites
	echo "$bareMinimumPackages,`echo $@ | sed 's/ /,/g'`"
}

function chrootGetImage
{
	echo "$chrootImage"
}

function chrootBuildContents
{
	echo "Build"
	debootstrap --no-check-gpg --include="$packages" --arch "$arch" "$chrootRelease" "$mountPoint" "$chrootMirror"

	return $?
}

function chrootBuildAll
{
	# Prepare
	chrootPrerequisites
	chrootCreateBareImage
	chrootMountImage

	# Main build
	if chrootBuildContents; then
		# Post build extras
		chrootMountExtras
		export DEBIAN_FRONTEND=noninteractive
		chrootKDETasksel
		chrootRun apt-get clean -y
		chrootUnMountExtras

		# Cleanup
		chrootUmountImage
		chrootCompress
	fi
}


