# GlobalProtect VPN With Okta Push 2FA

Need to connect your Linux desktop to a GlobalProtect VPN, but your company uses Okta Push 2FA? You've come to the right place!

## "Supported" Distros

This script was tested on Xubuntu 19.10 and CentOS 8. Only Xubuntu "works" but CentOS 8 is nearly working. This is all unsupported. YMMV.

## Installation

If you are running a recent Debian/Red Hat distro, you should be able to run `./install.sh`.

If not, well... here's what the script _does_.

* Installs OpenConnect version 8. Minimum requirement unless you want to patch stuff, but that's on you. You need a version that supports `--protocol=gp` so make it happen however.
* Fetches a copy of [gp-saml-gui](https://github.com/dlenski/gp-saml-gui.git).
* If it is not already installed, it fetches a [fake HIP report script](https://raw.githubusercontent.com/dlenski/openconnect/master/hipreport.sh) so the VPN thinks we're kosher.
* Installs whatever is required to run the aforementioned dependencies.

After that, edit `/etc/gp-okta.conf` and set `VPN_SERVER` to your VPN server domain name.

That's it.

## Connection

Again, if your system is script-friendly, just run `gp-okta.sh` and magic should happen.

If not, well... here's what the script _does_.

* Checks that some of the crap mentioned above is installed.
* Sources `/etc/gp-okta.conf` to get `VPN_SERVER`.i
* Executes `gp-saml-gui.py` and displays a WebKit window to log in via Okta.
* Evaluates the output of `gp-saml-gui.py` to get the needed variables for making the connection.
* Executes `openconnect` with all the correct flags.

## Known Issues

* CentOS 8 almost works, but DNS seems to be an issue.
* No NetworkManager integration yet, and it doesn't look good.
