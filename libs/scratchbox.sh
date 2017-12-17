# Stuff for working with scratch box.

function scratchboxAptBasedInstall
{
	echo "deb http://scratchbox.org/debian/ stable main" > /etc/apt/sources.list.d/scratchbox.list
	
	apt-get update
	# apt-get install --allow-unauthenticated scratchbox-core
	apt-get install scratchbox-core scratchbox-devkit-apt-https scratchbox-devkit-autotools-legacy scratchbox-devkit-debian-squeeze scratchbox-devkit-doctools scratchbox-devkit-git scratchbox-devkit-perl scratchbox-devkit-python-legacy scratchbox-devkit-qemu scratchbox-devkit-svn scratchbox-libs scratchbox-toolchain-cs2007q3-glibc2.5-arm7 scratchbox-toolchain-cs2007q3-glibc2.5-i486 scratchbox-toolchain-host-gcc
	
	modprobe binfmt_misc
}
