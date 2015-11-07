/*
 * Copyright (c) 2011-2015 THOMAS-Projekt (https://thomas-projekt.de)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Viewer.MainWindow : Gtk.Window {
    private Backend.SettingsManager settings_manager;
    private Backend.BusManager bus_manager;

    private Gtk.HeaderBar header_bar;

    private Gtk.StackSwitcher stack_switcher;

    private Gtk.ToolButton side_bar_toggle;

    private Gtk.Paned paned;

    private Gtk.Stack stack;

    private Widgets.ConfigurationPage configuration_page;
    private Widgets.CameraPage camera_page;

    private Widgets.SideBar side_bar;

    public MainWindow (Viewer.Application application) {
        this.set_application (application);

        settings_manager = new Backend.SettingsManager ();
        bus_manager = new Backend.BusManager (settings_manager);

        configure_gtk ();
        build_ui ();
        create_bindings ();
        connect_signals ();
    }

    private void configure_gtk () {
        Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
    }

    private void build_ui () {
        header_bar = new Gtk.HeaderBar ();
        header_bar.show_close_button = true;

        stack_switcher = new Gtk.StackSwitcher ();

        side_bar_toggle = new Gtk.ToolButton (null, null);
        side_bar_toggle.icon_name = (settings_manager.show_side_bar) ? "pane-hide-symbolic" : "pane-show-symbolic";

        header_bar.custom_title = stack_switcher;
        header_bar.pack_end (side_bar_toggle);

        this.set_titlebar (header_bar);

        paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        stack = new Gtk.Stack ();

        configuration_page = new Widgets.ConfigurationPage (settings_manager, bus_manager);
        camera_page = new Widgets.CameraPage ();

        stack.add_titled (configuration_page, "configuration", "Konfiguration");
        stack.add_titled (camera_page, "camera", "Kamera");

        side_bar = new Widgets.SideBar ();
        side_bar.no_show_all = true;

        stack_switcher.stack = stack;

        paned.pack1 (stack, true, false);
        paned.pack2 (side_bar, false, false);

        this.add (paned);
    }

    private void create_bindings () {
        /* Regelt die Sichtbarkeit der Seitenleiste */
        settings_manager.bind_property ("show-side-bar",
                                        side_bar,
                                        "visible",
                                        BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
    }

    private void connect_signals () {
        bus_manager.connection_failure.connect ((message) => {
            warning ("Verbindungsfehler: %s", message);

            /* TODO: Warnung grafisch anzeigen. */
        });

        bus_manager.action_failure.connect ((message) => {
            warning ("Zugriffsfehler: %s", message);

            /* TODO: Warnung grafisch anzeigen. */
        });

        side_bar_toggle.clicked.connect (() => {
            side_bar_toggle.set_icon_name ((settings_manager.show_side_bar = !settings_manager.show_side_bar) ? "pane-hide-symbolic" : "pane-show-symbolic");
        });
    }
}