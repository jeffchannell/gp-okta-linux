#!/usr/bin/env python3

"""gp-okta-indicator.py: A GlobalProtect VPN with Okta 2FA indicator applet"""

__author__ = "Jeff Channell"
__copyright__ = "Copyright 2019, Jeff Channell"
__credits__ = ["Jeff Channell"]
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Jeff Channell"
__email__ = "me@jeffchannell.com"
__status__ = "Prototype"

import gi
import os
import shlex
import signal
import subprocess
import sys

gi.require_version("Gtk", "3.0")
gi.require_version("AppIndicator3", "0.1")

from gi.repository import Gtk
from gi.repository import AppIndicator3 as appindicator
from gi.repository import GLib

class GpOktaLinuxIndicator:
    def __init__(self):
        # read configuration
        command = shlex.split("env -i bash -c 'source /etc/gp-okta.conf && env'")
        proc = subprocess.Popen(command, stdout = subprocess.PIPE)
        for line in proc.stdout:
            (key, _, value) = line.decode('utf-8').partition("=")
            os.environ[key.strip()] = value.strip()
        proc.communicate()

        self.vpn = os.environ.get("VPN_SERVER", "")
        if "" == self.vpn:
            print("VPN_SERVER not found in environment. Exiting.", file=sys.stderr)
            sys.exit(1)
        
        self.about = None
        self.indicator = appindicator.Indicator.new(
            "GpOktaLinuxIndicator",
            os.path.abspath("icons/disconnected.svg"),
            appindicator.IndicatorCategory.HARDWARE
        )
        self.indicator.set_status(appindicator.IndicatorStatus.ACTIVE)
        self.menu = Gtk.Menu()

        # add connection toggle menu item
        self.toggle = Gtk.MenuItem()
        self.toggle.set_label("Connect to %s" % self.vpn)
        self.toggle.connect("activate", self.toggle_connection)
        self.menu.append(self.toggle)
            
        # sep
        item = Gtk.SeparatorMenuItem()
        self.menu.append(item)
        
        # about me
        item = Gtk.MenuItem()
        item.set_label("About")
        item.connect("activate", self.show_about)
        self.menu.append(item)
        
        # add a quit menu item
        item = Gtk.MenuItem()
        item.set_label("Quit")
        item.connect("activate", self.quit)
        self.menu.append(item)
        
        # set the menu
        self.menu.show_all()
        self.indicator.set_menu(self.menu)
            
    def add_about_window_contents(self):
        text = Gtk.Label()
        text.set_markup(
            "<b>GlobalProtect with Okta 2FA Indicator</b>\n\n{}\n\n"
            "A GlobalProtect VPN with Okta 2FA indicator applet\n\n"
            "<a href=\"https://github.com/jeffchannell/gp-okta-linux\">"
            "https://github.com/jeffchannell/gp-okta-linux</a>\n\n"
            "<small>"
            "© 2019 Jeff Channell\n\n"
            "This program comes with absolutely no warranty.\n"
            "See the GNU General Public License, version 3 or later for details."
            "</small>".format(__version__)
        )
        text.set_line_wrap(True)
        text.set_justify(Gtk.Justification.CENTER)
        
        self.about.add(text)
            
    def destroy_about(self, widget, something):
        self.about = None
        return False

    def is_running(self):
        return os.path.isfile("/var/run/gp-okta.pid")
        
    def main(self):
        self.run_loop()
        Gtk.main()

    def quit(self, widget):
        subprocess.call([os.path.abspath("stop.sh")])
        Gtk.main_quit()
        
    def run_loop(self):
        if self.is_running():
            icon = "connected"
            icon_desc = "Connected to %s"
            label = "Disconnect from %s"
        else:
            icon = "disconnected"
            icon_desc = "Disconnected from %s"
            label = "Connect to %s"
        self.indicator.set_icon_full(os.path.abspath("icons/%s.svg" % icon), icon_desc % self.vpn)
        self.toggle.set_label(label % self.vpn)
        GLib.timeout_add_seconds(1, self.run_loop)
        
    def show_about(self, widget):
        if None == self.about:
            self.about = Gtk.Window()
            self.about.set_title("About GpOktaLinuxIndicator")
            self.about.set_keep_above(True)
            self.about.connect("delete-event", self.destroy_about)
            self.add_about_window_contents()
            
        self.about.set_position(Gtk.WindowPosition.CENTER)
        self.about.set_size_request(400, 200)
        self.about.show_all()
            
    def toggle_connection(self, widget):
        if self.is_running():
            script = "stop.sh"
        else:
            script = "start.sh"
        subprocess.Popen([os.path.abspath(script)])

def main():
    # allow app to be killed using ctrl+c
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    indicator = GpOktaLinuxIndicator()
    indicator.main()

if __name__ == '__main__':
    main()
