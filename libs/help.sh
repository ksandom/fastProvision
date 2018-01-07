#!/bin/bash
# Help

function requireParameters
{
    fileName="$1"
    requiredParameter="$2"
    
    if [ "$requiredParameter" == '' ]; then
        echo "Missing parameter."
        echo
        showComments "$fileName"
        exit 1
    fi
}

function showComments
{
    # Show the comments inside a file.
    fileName="$1"
    
    grep '^#' "$fileName" | tail -n+2
}
