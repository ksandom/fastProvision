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
	logFile="$mountPoint/var/log/fpBuild.log"
	echo "`getNow` $@" >> $logFile
}
