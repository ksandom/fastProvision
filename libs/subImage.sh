#!/bin/bash
# Mount sub images.

function getPartitionOffset
{
	fileName="$1"
	partitionNumber="$2"

	# TODO This is inefficient. Refactor.
	startSector=`fdisk -l "$fileName" | grep "img$partitionNumber" | awk '{print $2}'`
	sectorSize=`fdisk -l "$fileName" | grep 'Sector size' | cut -d: -f2 | cut -d\  -f2`

	let offset=$startSector*$sectorSize

	echo "$offset"
}

function mountSubParition
{
	fileName="$1"
	partitionNumber="$2"
	mountPoint="$3"
	
	mkdir -p "$mountPoint"
	mount -o loop,offset=`getPartitionOffset "$fileName" "$partitionNumber"` "$fileName" "$mountPoint"
}

