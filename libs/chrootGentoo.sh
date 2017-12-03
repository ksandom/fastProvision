#!/bin/bash
# Build a gentoo chroot.

chrootGentooCache="/tmp"
chrootGentooStage3URL="http://distfiles.gentoo.org/releases/arm/autobuilds/current-stage3-armv6j_hardfp/"
chrootGentooPortageURL="http://distfiles.gentoo.org/snapshots/"
chrootGentooPortageFile="portage-latest.tar.bz2"

function chrootGentooPrerequisites
{
	export chrootGentooPortageFullURL="$chrootGentooPortageURL$chrootGentooPortageFile"
	export chrootGentooPortageFullFile="$chrootGentooCache/$chrootGentooPortageFile"
}

function chrootGentooGetTarball
{
	echo "Get the stage3 tarball."
	stage3Name="`chrootGentooGetTarballName`"
	export stage3CacheName="$chrootGentooCache/$stage3Name"
	
	wget --continue "$chrootGentooStage3URL/$stage3Name" -O "$stage3CacheName"
}

function chrootGentooGetTarballName
{
	curl "$chrootGentooStage3URL" | grep 'href="stage' | sed 's/^.*href=//g' | cut -d\" -f2 | grep '\.bz2$'
}

function chrootGentooGetPortage
{
	echo "Get portage."
	wget --continue "$chrootGentooPortageFullURL" -O "$chrootGentooPortageFullFile"
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
	cp -R usefulStuff/gentoo/* "$mountPoint"
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
	chrootGentooPlaceHardCodedConfigs
	
	# Build build tools.
	
	# Retrieve all packages.
	
	# Build all pacakges.
	
	# Cleanup.
}

