# Downloads and installs chrome.

function installChrome
{
    if ! which google-chrome > /dev/null; then
        echo "Installing google chrome."
        tmpDir=/tmp/$$

        mkdir -p "$tmpDir"
        cd "$tmpDir"

        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        dpkg -i google-chrome*.deb

        cd ~-
        rmdir $tmpDir
    else
        echo "Google chrome is already installed."
    fi
}