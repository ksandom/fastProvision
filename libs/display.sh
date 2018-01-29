#!/bin/bash
# Stuff for display and logging.

function doing
{
	echo "doing: $@" >&2
	writeToLog "$@"
}

function log
{
	echo "log: $@"  >&2
	writeToLog "$@"
}

function logQuietly
{
	writeToLog "$@"
}

function writeToLog
{
	logDir="$mountPoint/var/log"
	
	if [ -d "$logDir" ] ; then
		logFile="$logDir/fpBuild.log"
	else
		logFile="/tmp/fpBuild-preImage.log"
	fi
	echo "`getNow` $@" >> $logFile
}

function warning
{
	message="$1"
	timeRemaining="${2:-5}"
	
	# Display the message and countdown.
	while [ $timeRemaining -gt 0 ]; do
		echo -n "WARNING: $message $timeRemaining "
		let timeRemaining=$timeRemaining-1
		sleep 1
	done
	echo -n "WARNING: $message EXPIRED "
}
