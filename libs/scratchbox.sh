# Stuff for working with scratch box.

function scratchboxAptBasedInstall
{
	echo "deb http://scratchbox.org/debian/ stable main" > /etc/apt/sources.list.d/scratchbox.list
	
	apt-get update
	# apt-get install --allow-unauthenticated scratchbox-core
	apt-get install scratchbox-core scratchbox-devkit-apt-https scratchbox-devkit-autotools-legacy scratchbox-devkit-debian-squeeze scratchbox-devkit-doctools scratchbox-devkit-git scratchbox-devkit-perl scratchbox-devkit-python-legacy scratchbox-devkit-qemu scratchbox-devkit-svn scratchbox-libs scratchbox-toolchain-cs2007q3-glibc2.5-arm7 scratchbox-toolchain-cs2007q3-glibc2.5-i486 scratchbox-toolchain-host-gcc
	
	modprobe binfmt_misc
}

function createScratchbox
{
	# Adapted from: Sailfish HardwareAdaptionDevelopmentKiti 1.1.2  documentaion.

	# Download the image.
	NAME=fp2
	PORT_ARCH=armv7hl
	SFE_SB2_TARGET=~/chroots/build/sb2
	DLFILE=~/chroots/cache/sbimage.tar.bz2
	TARBALL_URL=http://releases.sailfishos.org/sdk/latest/targets/targets.json
	TARBALL=$(curl $TARBALL_URL | grep "$PORT_ARCH.tar.bz2" | cut -d\" -f4)
	[-e $DLFILE ] || curl "$TARBALL" -o $DLFILE
	sudo mkdir -p $SFE_SB2_TARGET
	sudo tar --numeric-owner -pxjf $DLFILE -C $SFE_SB2_TARGET
	sudo chown -R $USER $SFE_SB2_TARGET
	cd $SFE_SB2_TARGET
	grep :$(id -u): /etc/passwd >> $SFE_SB2_TARGET/etc/passwd
	grep :$(id -g): /etc/group >> $SFE_SB2_TARGET/etc/group

	# Setup SB2.
	sb2-init -d -L "--sysroot=/" -C "--sysroot=/" \
		-c /usr/bin/qemu-arm-dynamic -m sdk-build \
		-n -N -t / $NAME \
		/opt/cross/bin/$PORT_ARCH-meego-linux-gnueabi-gcc
	sb2 -t $NAME -m sdk-install -R rpm --rebuilddb

}

