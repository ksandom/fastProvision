# fastProvision

A fast and filthy way to provision a desktop environment and build chroot images.

This was initially intended as a proof of concept to prove a point. But has actually become suitable for building chroot images in a flexible, automated way.

## Pre-requisites

* `debootstrap` - For apt based distributions.
* `wget`
* `curl`

On apt based distributions, you can install these like so

    sudo apt-get install debootstrap wget curl

## Installing it.

At the moment I simply run this from within the repo folder, so no installation is necessary. If this changes I'll post it here.

## Using it.

Browse through the profiles directory structure and find the thing that most closely matches your situation. Feel free to add more. Once you've found what you're looking for, just give it a run.

    sudo ./profiles/chroots/devuan-jezzie-armhf-desktop

## Debugging/Convenience

There are some profiles in `./profiles/convenience` that may be of interested to you.

Or particular interest are

* `./profiles/convenience/chrootMountExtras` - Mount things like /dev and /proc inside the chroot directory.
* `./profiles/convenience/chrootUnmountExtras` - The counterpart to mount. Use this when you're finished.
* `./profiles/convenience/chrootEnter` - Get inside the chroot to see what's going on. 
  * Note that the build and image architectures are the same. 
  * Note that if you are looking for a convenient way to get into a chroot environment, you should have a look at [linuxOnStuff](https://github.com/ksandom/linuxOnStuff/), which makes this stuff easy and threadsafe.
* `./profiles/convenience/chrootRun` - 
* `./profiles/convenience/gentoo-warmCache` - Downloads the stuff that will be used for jumpstarting a gentoo image. This is called automatically when you create an image, so it really only there fore debugging.


## Contributing

Make pull requests! :)

Stuff that's particularly useful
* Automate stuff in /libs that can be included in /profiles.
* Create profiles.

