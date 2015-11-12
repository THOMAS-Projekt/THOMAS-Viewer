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
    private static const uint16 CAMERA_STREAMER_PORT = 4243;

    private Backend.SettingsManager settings_manager;
    private Backend.BusManager bus_manager;
    private Backend.UDPRenderer udp_renderer;
    private Backend.JoystickManager joystick_manager;

    private Gtk.HeaderBar header_bar;

    private Gtk.StackSwitcher stack_switcher;

    private Gtk.ToolButton side_bar_toggle;

    private Gtk.Box main_box;

    private Gtk.InfoBar info_bar;
    private Gtk.Label info_label;

    private Gtk.Paned paned;

    private Gtk.Stack stack;

    private Widgets.ConfigurationPage configuration_page;
    private Widgets.CameraPage camera_page;

    private Widgets.SideBar side_bar;

    /* Die ID des aktuell laufenden Kamerastreames. */
    private int camera_streamer_id = -1;

    public MainWindow (Viewer.Application application) {
        this.set_application (application);

        settings_manager = new Backend.SettingsManager ();
        bus_manager = new Backend.BusManager (settings_manager);
        udp_renderer = new Backend.UDPRenderer (CAMERA_STREAMER_PORT);
        joystick_manager = new Backend.JoystickManager (bus_manager);

        configure_gtk ();
        build_ui ();
        create_bindings ();
        connect_signals ();
    }

    private void configure_gtk () {
        Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
    }

    private void build_ui () {
        this.set_default_size (1000, 700);

        header_bar = new Gtk.HeaderBar ();
        header_bar.show_close_button = true;

        stack_switcher = new Gtk.StackSwitcher ();

        side_bar_toggle = new Gtk.ToolButton (null, null);
        side_bar_toggle.icon_name = (settings_manager.show_side_bar) ? "pane-hide-symbolic" : "pane-show-symbolic";

        header_bar.custom_title = stack_switcher;
        header_bar.pack_end (side_bar_toggle);

        this.set_titlebar (header_bar);

        main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        info_bar = new Gtk.InfoBar ();
        info_bar.show_close_button = true;
        info_bar.message_type = Gtk.MessageType.INFO;

        info_label = new Gtk.Label ("Loading...");

        info_bar.get_content_area ().add (info_label);

        paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        stack = new Gtk.Stack ();

        configuration_page = new Widgets.ConfigurationPage (settings_manager, bus_manager, joystick_manager);
        camera_page = new Widgets.CameraPage (settings_manager, udp_renderer);

        stack.add_titled (configuration_page, "configuration", "Konfiguration");
        stack.add_titled (camera_page, "camera", "Kamera");

        side_bar = new Widgets.SideBar ();
        side_bar.no_show_all = true;

        stack_switcher.stack = stack;

        paned.pack1 (stack, true, false);
        paned.pack2 (side_bar, false, false);

        main_box.pack_start (info_bar, false, true);
        main_box.pack_end (paned, true, true);

        this.add (main_box);
    }

    private void create_bindings () {
        /* Regelt die Sichtbarkeit der Seitenleiste */
        settings_manager.bind_property ("show-side-bar",
                                        side_bar,
                                        "visible",
                                        BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
    }

    private void connect_signals () {
        /* Oberfläche initialisieren */
        this.show.connect (() => {
            info_bar.hide ();
        });

        bus_manager.connection_failure.connect ((message) => {
            warning ("Verbindungsfehler: %s", message);

            show_info_bar (Gtk.MessageType.ERROR, message);
        });

        bus_manager.action_failure.connect ((message) => {
            warning ("Zugriffsfehler: %s", message);

            show_info_bar (Gtk.MessageType.WARNING, message);
        });

        bus_manager.action_success.connect (() => {
            info_bar.hide ();
        });

        info_bar.response.connect (() => {
            info_bar.hide ();
        });

        stack.notify["visible-child-name"].connect (() => {
            if (stack.visible_child_name == "camera") {
                start_camera_stream ();
            } else {
                stop_camera_stream ();
            }
        });

        side_bar_toggle.clicked.connect (() => {
            side_bar_toggle.set_icon_name ((settings_manager.show_side_bar = !settings_manager.show_side_bar) ? "pane-hide-symbolic" : "pane-show-symbolic");
        });

        camera_page.stream_quality_changed.connect ((stream_quality) => {
            if (camera_streamer_id == -1) {
                return;
            }

            bus_manager.set_camera_stream_options (camera_streamer_id, stream_quality, stream_quality);
        });
    }

    private void show_info_bar (Gtk.MessageType message_type, string message) {
        info_bar.set_message_type (message_type);
        info_label.set_text (message);

        info_bar.show ();
    }

    private void start_camera_stream () {
        if (camera_streamer_id != -1) {
            /* Der Stream läuft bereits. */
            return;
        }

        string own_host = settings_manager.own_host.strip () == "" ? Environment.get_host_name () : settings_manager.own_host;

        bus_manager.start_camera_stream.begin (own_host, CAMERA_STREAMER_PORT, (obj, res) => {
            camera_streamer_id = bus_manager.start_camera_stream.end (res);

            bus_manager.set_camera_stream_options (camera_streamer_id, settings_manager.stream_quality, settings_manager.stream_quality);
        });
    }

    private void stop_camera_stream () {
        if (camera_streamer_id == -1) {
            /* Es läuft kein Stream mehr. */
            return;
        }

        bus_manager.stop_camera_stream (camera_streamer_id);
        camera_streamer_id = -1;
    }
}