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

    private static const int KEY_CONTROL_MOTOR_SPEED = 255;

    private Backend.SettingsManager settings_manager;
    private Backend.BusManager bus_manager;
    private Backend.UDPRenderer udp_renderer;
    private Backend.JoystickManager joystick_manager;
    private Backend.ServiceBrowser service_browser;

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
    private Widgets.MapsPage maps_page;

    private Widgets.SideBar side_bar;

    private bool is_fullscreened = false;

    /* Die ID des aktuell laufenden Kamerastreames. */
    private int camera_streamer_id = -1;

    /* Zustandsvariablen für die Analyse der Tastendrücke */
    private bool key_up_pressed = false;
    private bool key_down_pressed = false;
    private bool key_left_pressed = false;
    private bool key_right_pressed = false;
    private bool key_space_pressed = false;

    public MainWindow (Viewer.Application application) {
        this.set_application (application);

        settings_manager = new Backend.SettingsManager ();
        bus_manager = new Backend.BusManager (settings_manager);
        udp_renderer = new Backend.UDPRenderer (CAMERA_STREAMER_PORT);
        joystick_manager = new Backend.JoystickManager (bus_manager);
        service_browser = new Backend.ServiceBrowser ();

        configure_gtk ();
        build_ui ();
        create_bindings ();
        connect_signals ();
    }

    private void configure_gtk () {
        Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
    }

    private void build_ui () {
        this.set_size_request (1000, 600);
        this.set_default_size (1200, 800);
        this.events |= Gdk.EventMask.KEY_PRESS_MASK |
                       Gdk.EventMask.KEY_RELEASE_MASK;

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
        maps_page = new Widgets.MapsPage (bus_manager);

        stack.add_titled (configuration_page, "configuration", "Konfiguration");
        stack.add_titled (camera_page, "camera", "Kamera");
        stack.add_titled (maps_page, "maps", "Karten");

        side_bar = new Widgets.SideBar (bus_manager);
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

        this.key_press_event.connect ((event) => {
            /* Vollbild-Funktion ist immer Verfügbar */
            if (event.keyval == Gdk.Key.F11) {
                toggle_fullscreen ();

                return Gdk.EVENT_STOP;
            }

            /* Steuerungstasten auf Konfigurationsseite ignorieren */
            if (stack.visible_child_name == "configuration") {
                return Gdk.EVENT_PROPAGATE;
            }

            /* Falls die Taste ein Relay einschalten soll, weitere Verarbeitung abbrechen */
            if (process_key_relay_control (event.keyval, true)) {
                return Gdk.EVENT_STOP;
            }

            switch (event.keyval) {
                case Gdk.Key.Up: key_up_pressed = true; break;
                case Gdk.Key.Down: key_down_pressed = true; break;
                case Gdk.Key.Left: key_left_pressed = true; break;
                case Gdk.Key.Right: key_right_pressed = true; break;
                case Gdk.Key.space: key_space_pressed = true; break;

                default:

                    return Gdk.EVENT_PROPAGATE;
            }

            process_key_control ();

            return Gdk.EVENT_STOP;
        });

        this.key_release_event.connect ((event) => {
            /* Steuerungstasten auf Konfigurationsseite ignorieren */
            if (stack.visible_child_name == "configuration") {
                return Gdk.EVENT_PROPAGATE;
            }

            /* Falls die Taste ein Relay ausschalten soll, weitere Verarbeitung abbrechen */
            if (process_key_relay_control (event.keyval, false)) {
                return Gdk.EVENT_STOP;
            }

            switch (event.keyval) {
                case Gdk.Key.Up: key_up_pressed = false; break;
                case Gdk.Key.Down: key_down_pressed = false; break;
                case Gdk.Key.Left: key_left_pressed = false; break;
                case Gdk.Key.Right: key_right_pressed = false; break;
                case Gdk.Key.space: key_space_pressed = false; break;

                default:

                    return Gdk.EVENT_PROPAGATE;
            }

            process_key_control ();

            return Gdk.EVENT_STOP;
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

        service_browser.thomas_discovered.connect (configuration_page.set_address);

        info_bar.response.connect (() => {
            info_bar.hide ();
        });

        stack.notify["visible-child-name"].connect (() => {
            if (stack.visible_child_name == "camera") {
                start_camera_stream ();
            } else {
                stop_camera_stream ();
            }

            camera_page.reset ();
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

    private void toggle_fullscreen () {
        if (is_fullscreened) {
            this.unfullscreen ();
        } else {
            this.fullscreen ();
        }

        is_fullscreened = !is_fullscreened;
    }

    private bool process_key_relay_control (uint keyval, bool state) {
        int relay_port = 0;

        switch (keyval) {
            case Gdk.Key.@1: relay_port = 1; break;
            case Gdk.Key.@2: relay_port = 2; break;
            case Gdk.Key.@3: relay_port = 3; break;
            case Gdk.Key.@4: relay_port = 4; break;
            case Gdk.Key.@5: relay_port = 5; break;
            case Gdk.Key.@6: relay_port = 6; break;
            case Gdk.Key.@7: relay_port = 7; break;
            case Gdk.Key.@8: relay_port = 8; break;

            default:

                return false;
        }

        bus_manager.set_relay (relay_port, state);

        return true;
    }

    private void process_key_control () {
        /* Leertaste soll als Stopp-Taste agieren */
        if (key_space_pressed) {
            /* Sofort anhalten */
            bus_manager.set_motor_speed (Backend.BusManager.Motor.BOTH, 0);
        } else {
            int speed_left = 0, speed_right = 0;

            /* Geschwindigkeitswerte für einfache Tastendrücke setzen */
            if (key_up_pressed) {
                speed_left = (speed_right = KEY_CONTROL_MOTOR_SPEED);
            } else if (key_down_pressed) {
                speed_left = (speed_right = -KEY_CONTROL_MOTOR_SPEED);
            } else if (key_left_pressed) {
                speed_left = -(speed_right = KEY_CONTROL_MOTOR_SPEED);
            } else if (key_right_pressed) {
                speed_left = -(speed_right = -KEY_CONTROL_MOTOR_SPEED);
            }

            /* Geschwindigkeitswerte bei doppelten Tastendrücken korrigieren */
            if ((key_up_pressed || key_down_pressed) && key_left_pressed) {
                speed_left = 0;
            }

            if ((key_up_pressed || key_down_pressed) && key_right_pressed) {
                speed_right = 0;
            }

            /* Neue Geschwindigkeitswerte senden */
            bus_manager.accelerate_to_motor_speed (Backend.BusManager.Motor.LEFT, speed_left);
            bus_manager.accelerate_to_motor_speed (Backend.BusManager.Motor.RIGHT, speed_right);
        }
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