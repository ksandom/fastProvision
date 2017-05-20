# This contains the functions to manage the packages.

function packages
{
    echo "Will install: $1"
    apt-get install -y "$1"
}
