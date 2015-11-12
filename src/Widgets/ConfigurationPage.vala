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

public class Viewer.Widgets.ConfigurationPage : Gtk.Grid {
    public Backend.SettingsManager settings_manager { private get; construct; }
    public Backend.BusManager bus_manager { private get; construct; }
    public Backend.JoystickManager joystick_manager { private get; construct; }

    private Gtk.Entry host_entry;
    private Gtk.Entry own_host_entry;
    private Gtk.ComboBoxText joystick_selection;

    private int rows = 0;

    public ConfigurationPage (Backend.SettingsManager settings_manager, Backend.BusManager bus_manager, Backend.JoystickManager joystick_manager) {
        Object (settings_manager: settings_manager, bus_manager: bus_manager, joystick_manager: joystick_manager);

        build_ui ();
        list_joysticks ();
        connect_signals ();
    }

    private void build_ui () {
        this.margin = 24;
        this.column_spacing = 24;
        this.row_spacing = 24;
        this.halign = Gtk.Align.CENTER;
        this.valign = Gtk.Align.CENTER;

        host_entry = new Gtk.Entry ();
        host_entry.text = settings_manager.last_host;

        own_host_entry = new Gtk.Entry ();
        own_host_entry.text = settings_manager.own_host;
        own_host_entry.placeholder_text = Environment.get_host_name ();

        joystick_selection = new Gtk.ComboBoxText ();
        joystick_selection.append ("none", "Deaktiviert");

        add_entry ("Server-Adresse:", host_entry);
        add_entry ("Eigene Adresse:", own_host_entry);
        add_entry ("Joystick:", joystick_selection);
    }

    private void add_entry (string title, Gtk.Widget widget) {
        Gtk.Label title_label = new Gtk.Label (title);
        title_label.halign = Gtk.Align.END;

        widget.set_size_request (200, -1);

        this.attach (title_label, 0, rows, 1, 1);
        this.attach (widget, 1, rows, 1, 1);

        rows++;
    }

    private void list_joysticks () {
        Gee.Collection<Backend.Joystick> joysticks = joystick_manager.get_joysticks ();

        foreach (Backend.Joystick joystick in joysticks) {
            joystick_selection.append (joystick.input_device,
                                       "%s [%s]".printf (joystick.device_name, joystick.input_device));
        }

        joystick_selection.set_active (joysticks.size > 0 ? 1 : 0);
    }

    private void connect_signals () {
        host_entry.changed.connect (() => {
            settings_manager.last_host = host_entry.text;

            bus_manager.invalidate_connection ();
        });

        own_host_entry.changed.connect (() => {
            settings_manager.own_host = own_host_entry.text;
        });

        joystick_selection.changed.connect (() => {
            joystick_manager.select_joystick (joystick_selection.get_active () == 0 ? null : joystick_selection.get_active_id ());
        });
    }
}