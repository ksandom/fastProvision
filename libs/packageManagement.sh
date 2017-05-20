# This contains the functions to manage the packages.

function packages
{
    echo "Packages: Will install: $@"
    apt-get install -y "$@"
}
