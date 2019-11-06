#!/usr/bin/env bash

# Tested on Xubuntu 19.10

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function create_desktop_file {
    if [ -d "${1}" ]; then
        desktop="${1}/gp-okta.desktop"
        echo "[Desktop Entry]" > "${desktop}"
        echo "Encoding=UTF-8" >> "${desktop}"
        echo "Name=GlobalProtect Okta 2FA" >> "${desktop}"
        echo "GenericName=gp-okta" >> "${desktop}"
        echo "Comment=GlobalProtect Okta 2FA Indicator App" >> "${desktop}"
        echo "Terminal=false" >> "${desktop}"
        echo "Type=Application" >> "${desktop}"
        echo "Categories=" >> "${desktop}"
        echo "Exec=bash -c 'cd ${DIR} && ./indicator.py'" >> "${desktop}"
        echo "Icon=${DIR}/icons/connected.svg" >> "${desktop}"
    fi
}

autostart_dir="${HOME}/.config/autostart"
if ! [ -d "${autostart_dir}" ]; then
    mkdir -p "${autostart_dir}" > /dev/null 2>&1
fi
create_desktop_file "${autostart_dir}"
setsid "${DIR}/indicator.py" &
