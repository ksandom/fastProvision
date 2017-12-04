#!/bin/bash
# Build a gentoo chroot.

chrootGentooCache=~/chroots/cache
chrootGentooStage3URL="http://distfiles.gentoo.org/releases/arm/autobuilds/current-stage3-armv6j_hardfp/"
chrootGentooPortageURL="http://distfiles.gentoo.org/snapshots/"
chrootGentooPortageFile="portage-latest.tar.bz2"

function chrootGentooPrerequisites
{
	mkdir -p "$chrootGentooCache"
	export chrootGentooPortageFullURL="$chrootGentooPortageURL$chrootGentooPortageFile"
	export chrootGentooPortageFullFile="$chrootGentooCache/$chrootGentooPortageFile"
}

function chrootGentooGetTarball
{
	echo "Get the stage3 tarball."
	stage3Name="`chrootGentooGetTarballName`"
	export stage3CacheName="$chrootGentooCache/$stage3Name"
	
	wget --continue "$chrootGentooStage3URL/$stage3Name" -O "$stage3CacheName"
	# TODO Verify the download.
}

function chrootGentooGetTarballName
{
	# TODO At the moment this will get the correct image for AMD64 by luck. It really needs to be foltered correctly so that it will be reliable, while still working for other architectures.
	curl "$chrootGentooStage3URL" | grep 'href="stage' | sed 's/^.*href=//g' | cut -d\" -f2 | grep '\.bz2$' | head -n 1
}

function chrootGentooGetPortage
{
	echo "Get portage."
	wget --continue "$chrootGentooPortageFullURL" -O "$chrootGentooPortageFullFile"
	# TODO Verify the download.
}

function chrootGentooExtractTarball
{
	echo "Extract the tarball."
	tar -C "$mountPoint" -xjpf "$stage3CacheName"
}

function chrootGentooExtractPortage
{
	echo "Extract portage."
	tar -C "$mountPoint/usr" -xjpf "$chrootGentooPortageFullFile"
}

function chrootGentooPlaceHardCodedConfigs
{
	echo "Place hard coded configs."
	cp -R $startDir/usefulStuff/gentoo/* "$mountPoint"
}

function chrootGentooSetupDNS
{
	cp /etc/resolv.conf "$mountPoint/etc/resolv.conf"
}

function chrootGentooSetCompileThreads
{
	echo "MAKEOPTS=\"-j5\"" >> "$mountPoint/etc/portage/make.conf"
}

function chrootGentooSetupUSEFlags
{
	echo "USR=\"-systemd\"" >> "$mountPoint/etc/portage/make.conf"
}

function chrootGentooBuildBuildTools
{
	chrootRun emerge -1 sys-devel/gcc && \
	chrootRun emerge -1 sys-devel/binutils && \
	chrootRun emerge -1 sys-libs/glibc && \
	chrootRun emerge -e @world
	chrootRun emerge --depclean
}

function chrootGentooBuildAll
{
	# Get config and directories sorted.
	chrootPrerequisites
	chrootGentooPrerequisites
	
	# Create the blank image.
	chrootCreateBareImage
	chrootMountImage
	
	# Get starting point.
	chrootGentooGetTarball
	chrootGentooGetPortage
	
	# Place the initial contents.
	chrootGentooExtractTarball
	chrootGentooExtractPortage
	
	# Configure.
	chrootGentooSetupDNS
	chrootGentooSetupUSEFlags
	#chrootGentooPlaceHardCodedConfigs
	chrootMountExtras
	
	# Build build tools.
	chrootGentooBuildBuildTools
	
	# Retrieve all packages.
	
	# Build all pacakges.
	
	# Cleanup.
	chrootUnMountExtras
}

