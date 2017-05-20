# Downloads and installs chrome.

packagesChromePrereqs="libappindicator1"

function preFetchChrome
{
    if ! which google-chrome > /dev/null; then
        fetchChrome
    fi
}

function fetchChrome
{
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
}

function installChrome
{
    if ! which google-chrome > /dev/null; then
        echo "Installing google chrome."

        dpkg -i google-chrome*.deb
    else
        echo "Google chrome is already installed."
    fi
}