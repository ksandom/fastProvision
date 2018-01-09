#!/bin/bash
# Build a gentoo chroot.

chrootGentooCache=~/chroots/cache
chrootGentooStage3URL="http://distfiles.gentoo.org/releases/arm/autobuilds/current-stage3-armv6j_hardfp/"
chrootGentooPortageURL="http://distfiles.gentoo.org/snapshots/"
chrootGentooPortageFile="portage-latest.tar.bz2"

function chrootGentooPrerequisites
{
	doing "Chroot prerequisites."
	mkdir -p "$chrootGentooCache"
	export chrootGentooPortageFullURL="$chrootGentooPortageURL$chrootGentooPortageFile"
	export chrootGentooPortageFullFile="$chrootGentooCache/$chrootGentooPortageFile"
}

function chrootGentooGetTarball
{
	doing "Get the stage3 tarball."
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
	doing "Get portage to $chrootGentooPortageFullFile."
	wget --continue "$chrootGentooPortageFullURL" -O "$chrootGentooPortageFullFile"
	# TODO Verify the download.
}

function chrootGentooExtractTarball
{
	doing "Extract the tarball."
	tar -C "$mountPoint" -xjpf "$stage3CacheName"
}

function chrootGentooExtractPortage
{
	doing "Extract portage."
	tar -C "$mountPoint/usr" -xjpf "$chrootGentooPortageFullFile"
	chrootGentooBackupMakeConf
}

function chrootGentooPlaceHardCodedConfigs
{
	doing "Place hard coded configs."
	cp -R $startDir/usefulStuff/gentoo/* "$mountPoint"
}

function chrootGentooSetupDNS
{
	doing "Setup DNS."
	cp /etc/resolv.conf "$mountPoint/etc/resolv.conf"
}

function chrootGentooBackupMakeConf
{
	doing "Backup make.conf."
	cp "$mountPoint/etc/portage/make.conf" "$mountPoint/etc/portage/make.conf.backup"
}

function chrootGentooSetCompileThreads
{
	doing "Set compile threads."
	echo "MAKEOPTS=\"-j5\"" >> "$mountPoint/etc/portage/make.conf"
}

function chrootGentooSetupUSEFlags
{
	doing "Setup USE flags."
	echo "USE=\"X -systemd -vlc xkb pcre16\"" >> "$mountPoint/etc/portage/make.conf"
}

function chrootGentooRemoveMMX
{
	doing "Remove MMX."
	case $arch in
		armv7hl)
			echo "No arm specific CPU flags yet." >&2
		;;
		*)
			echo "X86 specific flags." >&2
			chrootRun sed -i 's/^CPU_FLAGS_X86=".*"/CPU_FLAGS_X86=""/g' /etc/portage/make.conf
		;;
	esac
	
	chrootRun sed -i 's/^CFLAGS=".*"/CFLAGS="-O2 -pipe -march=native -mtune=native"/g' /etc/portage/make.conf
}

function chrootGentooHackPortageConfigIssue
{
	doing "Apply short term hack for missmatch between portage and the base image."
	echo "############# Applying short term hack for missmatch between portage and the base image. #############"
	[ -e /usr/portage/gentoo ] || chrootRun ln -s /usr/portage /usr/portage/gentoo
}

function chrootGentooKDEProfile
{
	doing "KDE profile."
	case $darch in
		x86)
			echo "Choosing the profile for non-arm." >&2
			profileNumber=`chrootRun eselect profile list | grep plasma | grep -v systemd | cut -d\[ -f2 | cut -d\] -f1 | tail -n 1`
		;;
		*)
			echo "Choosing the profile for arm." >&2
			profileNumber=`chrootRun eselect profile list | grep desktop | grep -v gnome | cut -d\[ -f2 | cut -d\] -f1 | tail -n 1`
		;;
	esac
	echo "Choosing plasma profile $profileNumber."
	chrootRun eselect profile set $profileNumber
}

function chrootGentooKDEPrerequisites
{
	doing "KDE Prerequisites."
	# TODO finish this chrootRun emerge 
	echo "###### this isn't finished."
}

function chrootGentooInstallKDE
{
	doing "Install KDE."
	# TODO dbus
	# TODO polkit
	# TODO udisks
	# TODO udev
	# TODO consolekit
	# TODO elogind - maybe not needed?
	# TODO systemd - for sessions tracker. I don't think this is needed for my usecase.
	chrootRun emerge -1 --nodeps libudev && \
	chrootRun emerge -1 qtgui  && \
	chrootRun emerge -1 --nodeps qtxml   && \
	chrootRun emerge -1 perl  && \
	chrootRun emerge -1 --autounmask-write openssl qtcore qtdbus qtwidgets qtdeclarative qtnetwork qtxmlpatterns qttest perl && \
	chrootRun emerge -n @world && \
	chrootRun emerge kde-plasma/plasma-meta
	
	return $?
}

function chrootGentooBuildBuildTools
{
	doing "Build the build tools."
	#chrootGentooKDEProfile
	chrootRun emerge --sync && \
	chrootRun emerge -1 sys-apps/portage && \
	chrootRun emerge -1 sys-devel/gcc && \
	chrootRun emerge -1 sys-devel/binutils && \
	chrootRun emerge -1 sys-libs/glibc && \
	chrootRun emerge vim esearch && \
	chrootRun eupdatedb && \
	chrootRun emerge -e @world && \
	chrootRun emerge --depclean
	
	return $?
}

function chrootGentooBasicGraphicalChrooting
{
	chrootRun emerge tigervnc xterm
	chrootRun chmod 755 /etc/X11/xinit/xinitrc
}

function chrootGentooBuildAll
{
	# Get config and directories sorted.
	chrootPrerequisites
	chrootGentooPrerequisites
	
	# Get starting point.
	chrootGentooGetPortage
	chrootGentooGetTarball
	
	# Create the blank image.
	chrootCreateBareImage
	chrootMountImage
	
	# Place the initial contents.
	chrootGentooExtractTarball
	chrootGentooExtractPortage
	
	# Configure.
	chrootGentooHackPortageConfigIssue
	#chrootGentooKDEProfile
	chrootGentooSetupDNS
	chrootGentooRemoveMMX
	chrootGentooSetupUSEFlags
	chrootGentooPlaceHardCodedConfigs
	chrootMountExtras
	
	# Build build tools.
	chrootGentooBuildBuildTools
	
	# Build graphical stuff
	chrootGentooBasicGraphicalChrooting
	chrootGentooInstallKDE
	
	
	# Cleanup.
	chrootUnMountExtras
}

function chrootGentooBuildLite
{
	# Get config and directories sorted.
	chrootPrerequisites
	chrootGentooPrerequisites
	
	# Get starting point.
	chrootGentooGetPortage
	chrootGentooGetTarball
	
	# Create the blank image.
	chrootCreateBareImage
	chrootMountImage
	
	# Place the initial contents.
	chrootGentooExtractTarball
	chrootGentooExtractPortage
	
	# Configure.
	chrootGentooHackPortageConfigIssue
	chrootGentooSetupDNS
	chrootGentooRemoveMMX
	chrootGentooSetupUSEFlags
	chrootGentooPlaceHardCodedConfigs
	chrootMountExtras
	
	# Build build tools.
	chrootGentooBuildBuildTools
	chrootGentooBasicGraphicalChrooting
	chrootGentooInstallKDE
	
	# Cleanup.
	chrootUnMountExtras
}

