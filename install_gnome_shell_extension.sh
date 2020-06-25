#!/usr/bin/env bash

# Tested on Xubuntu 19.10

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if ! [[ $(command -v "gnome-extensions") = "" ]]; then
    ext="gp-okta-linux@jeffchannell.com"
    exts="${HOME}/.local/share/gnome-shell/extensions"
    echo "Installing Gnome Extension to ${exts}"
    if [ ! -d "${exts}" ]; then
        mkdir -p "${exts}" > /dev/null 2>&1
    fi
    ln -s "${DIR}" "${exts}/${ext}"
    gnome-extensions enable "${ext}"
    killall -3 gnome-shell
elif ! [[ $(command -v "gnome-shell-extension-tool") = "" ]]; then
    ext="gp-okta-linux@jeffchannell.com"
    exts="${HOME}/.local/share/gnome-shell/extensions"
    echo "Installing Gnome Extension to ${exts}"
    if [ ! -d "${exts}" ]; then
        mkdir -p "${exts}" > /dev/null 2>&1
    fi
    ln -s "${DIR}" "${exts}/${ext}"
    gnome-shell-extension-tool -e "${ext}"
fi
