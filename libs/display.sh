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
