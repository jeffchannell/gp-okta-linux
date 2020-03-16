# GlobalProtect VPN With Okta Push 2FA

Need to connect your Linux desktop to a GlobalProtect VPN, but your company uses Okta Push 2FA? You've come to the right place!

## "Supported" Distros

This script was tested on Xubuntu 19.10, CentOS 8 and OpenSUSE Tumbleweed. Only Xubuntu and OpenSUSE "works" but CentOS 8 is nearly working. This is all unsupported. YMMV.

## Installation

If you are running a recent Debian/Red Hat distro, you should be able to run `./install.sh`.

If not, well... here's what the script _does_.

* Installs OpenConnect version 8. Minimum requirement unless you want to patch stuff, but that's on you. You need a version that supports `--protocol=gp` so make it happen however.
* Fetches a copy of [gp-saml-gui](https://github.com/dlenski/gp-saml-gui.git).
* If it is not already installed, it fetches a [fake HIP report script](https://raw.githubusercontent.com/dlenski/openconnect/master/hipreport.sh) so the VPN thinks we're kosher.
* Installs whatever is required to run the aforementioned dependencies.

After that, edit `/etc/gp-okta.conf` and set `VPN_SERVER` to your VPN server domain name, if you somehow failed to enter the VPN domain during install.

Finally, if you desire a UI to enable or disable this, check out the other install scripts here.

That's it.

## Connection

Again, if your system is script-friendly, just run `start.sh` and magic should happen.

If not, well... here's what the script _does_.

* Checks that some of the crap mentioned above is installed.
* Sources `/etc/gp-okta.conf` to get `VPN_SERVER`.
* Executes `gp-saml-gui.py` and displays a WebKit window to log in via Okta.
* Evaluates the output of `gp-saml-gui.py` to get the needed variables for making the connection.
* Executes `openconnect` with all the correct flags.

## Disconnect

Run `stop.sh`. Or kill the running openconnect process. Whatever.

## Known Issues

* CentOS 8 almost works, but DNS is to be an issue. I don't know why.
* No NetworkManager integration yet, and it doesn't look good.
* Some Gnome Shell installations may require gnome-tweaks to actually enable the indicator applet.
* If you use i3wm as your window manager, please make sure to run `pkttyagent --process $$ &` before calling `openconnect` command inside either `start.sh` and `stop.sh` files.  
