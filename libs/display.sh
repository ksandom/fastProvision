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

function writeToLog
{
	logDir="$mountPoint/var/log"
	
	if [ -d "$logDir" ]; then
            logFile="$logDir/fpBuild.log"
            echo "`getNow` $@" >> $logFile
	fi
}

function warning
{
	message="$1"
	timeRemaining="${2:-5}"
	
	# Display the message and countdown.
	while [ $timeRemaining -gt 0 ]; then
		echo -n "WARNING: $message $timeRemaining "
		let timeRemaining=$timeRemaining-1
		sleep 1
	fi
	echo -n "WARNING: $message EXPIRED "
}
