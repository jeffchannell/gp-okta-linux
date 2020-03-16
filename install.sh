#!/usr/bin/env bash

# Tested on Xubuntu 19.10, CentOS 8 and OpenSUSE Tumbleweed

set -e

# make sure script is running as root
if ! [ $(id -u) = 0 ]; then
    >&2 echo "Script should be run as root"
    exit 1
fi

function install_conf {
    if [ ! -f /etc/gp-okta.conf ]; then
        echo "export VPN_SERVER=${1}" > /etc/gp-okta.conf
    fi
}

function install_gp_saml_gui {
    if [ ! -d /opt/gp-saml-gui ]; then
        git clone https://github.com/dlenski/gp-saml-gui.git /opt/gp-saml-gui
    fi
}

function install_hipreport {
    # We are not using the master branch because the project was deprecated.
    # This is the most recent version of the hipreport.sh file.
    # TODO: We should review how to procceed once this project has been
    # deprecated. Maybe add this hipreport to our project.
    HIPREPORT_SRC='https://raw.githubusercontent.com/dlenski/openconnect/034dba1b6e365e76aa1b05f6a0f6f0fcd206e38f/hipreport.sh'
    HIPREPORT_SCRIPT=/usr/libexec/openconnect/hipreport.sh
    # mkdir for sources, if not available
    if [ ! -d /usr/libexec/openconnect ]; then
        mkdir -p /usr/libexec/openconnect
    fi
    # download HIP report script
    if [ ! -f "${HIPREPORT_SCRIPT}" ]; then
        wget -O "${HIPREPORT_SCRIPT}" "${HIPREPORT_SRC}"
        chmod +x "${HIPREPORT_SCRIPT}"
    fi
}

# read desired VPN server here
VPN_SERVER_ATTEMPTS=3
VPN_SERVER=
if [ -f /etc/gp-okta.conf ]; then
    source /etc/gp-okta.conf
fi
while [ "" = "${VPN_SERVER}" ]; do
    read -p "VPN Server: " VPN_SERVER
    if [ "" = "${VPN_SERVER}" ]; then
        VPN_SERVER_ATTEMPTS=$(($VPN_SERVER_ATTEMPTS-1))
    fi
    if [ 0 = $VPN_SERVER_ATTEMPTS ]; then
        exit 1
    fi
done

if [ "" = "${VPN_SERVER}" ]; then
    >&2 echo "VPN Server not set. Edit /etc/gp-okta.conf before starting VPN."
fi

# OpenSUSE distribution. Keep this if block as the first one
# because OpenSUSE often creates a link for 'apt' command pointing to
# zypper. It would fall into the Ubuntu 'if' block below by mistake.
if ! [[ $(command -v "zypper") = "" ]]; then
    zypper refresh
    zypper install --no-confirm \
           git wget openconnect python3-gobject python3-lxml python3-requests
    install_conf "${VPN_SERVER}"
    install_hipreport
    install_gp_saml_gui

# ubuntu
elif ! [[ $(command -v "apt") = "" ]]; then
    apt update
    apt -y install \
        git wget openconnect \
        python3-gi gir1.2-gtk-3.0 gir1.2-webkit2-4.0 \
        python-lxml python-requests
    install_conf "${VPN_SERVER}"
    install_hipreport
    install_gp_saml_gui

# centos
elif ! [[ $(command -v "yum") = "" ]]; then
    yum -y update
    yum -y install epel-release
    yum -y install openconnect vpnc-script
    yum -y install git
    install_conf "${VPN_SERVER}"
    install_hipreport
    install_gp_saml_gui

# unknown
else
    >&2 echo "You are not running a Debian/Red Hat/OpenSUSE derivative. Sorry."
    exit 1
fi
