# This contains the functions to manage the packages.
# The idea of this it to let apt, which is a very mature package manager, do it's stuff in one go, rather than micro-managing it all the way.

function packages
{
    echo "Packages: Will install: $@"
    apt-get update
    apt-get install -y "$@"
    
    # This magically fixes dependencies that could not be resolved the first time around.
    apt-get --fix-broken install -y
    apt-get install -y "$@"
}
