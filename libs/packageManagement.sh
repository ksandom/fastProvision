# This contains the functions to manage the packages.
# The idea of this it to let apt, which is a very mature package manager, do it's stuff in one go, rather than micro-managing it all the way.

function packages
{
    echo "Packages: Will install: $@"
    apt-get install -y "$@"
}
