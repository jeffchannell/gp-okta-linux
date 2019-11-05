'use strict';

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Main = imports.ui.main;
const Mainloop = imports.mainloop;

const Gio = imports.gi.Gio;
const GLib = imports.gi.GLib;
const GObject = imports.gi.GObject;
const PanelMenu = imports.ui.panelMenu;
const St = imports.gi.St;

const Config = imports.misc.config;
const SHELL_MINOR = parseInt(Config.PACKAGE_VERSION.split('.')[1]);

var GpOktaLinuxIndicator = class GpOktaLinuxIndicator extends PanelMenu.Button {
    _init() {
        super._init(0.0, `${Me.metadata.name} Indicator`, true);

        // add icons
        let icon_dir = Me.dir.get_path() + `/icons/`;

        let discon_icon_file = Gio.File.new_for_path(icon_dir + `disconnected.svg`)
        this.discon_icon = new Gio.FileIcon({file: discon_icon_file});

        let con_icon_file = Gio.File.new_for_path(icon_dir + `connected.svg`)
        this.con_icon = new Gio.FileIcon({file: con_icon_file});

        this.icon = new St.Icon({
            gicon: this.discon_icon,
            style_class: `system-status-icon`
        });
        this.actor.add_child(this.icon);
        
        this.menu.toggle = function() {
            run_local(`toggle.sh`);
        };

        let $ = this;

        Mainloop.timeout_add(500, function () {
            $.icon.gicon = is_running() ? $.con_icon : $.discon_icon;
            return true;
        });
    }
}

if (SHELL_MINOR > 30) {
    GpOktaLinuxIndicator = GObject.registerClass(
        {GTypeName: `GpOktaLinuxIndicator`},
        GpOktaLinuxIndicator
    );
}

var indicator = null;

function init()
{
}

function enable()
{
    indicator = new GpOktaLinuxIndicator();
    Main.panel.addToStatusArea(`${Me.metadata.name} Indicator`, indicator);
}

function disable()
{
    run_local(`toggle.sh stop`);
    if (indicator) {
        indicator.destroy();
        indicator = null;
    }
}

function is_running()
{
    return `0` === run(`bash -c '[[ -f /var/run/gp-okta.pid ]]; echo -n $?'`);
}

function run(cmd)
{
    let ret = GLib.spawn_command_line_sync(cmd);
    global.log(ret);
    return ret[1].toString();
}

function run_local(cmd)
{
    return run(Me.dir.get_path() + `/` + cmd);
}
