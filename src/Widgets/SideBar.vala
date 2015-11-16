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

public class Viewer.Widgets.SideBar : Gtk.Grid {
    public Backend.BusManager bus_manager { private get; construct; }

    private Gtk.Label cpu_load_field;
    private Gtk.Label memory_usage_field;
    private Gtk.Label free_drive_space_field;

    private Gtk.Label net_load_in_field;
    private Gtk.Label net_load_out_field;

    private Gtk.Label wifi_ssid_field;
    private Gtk.Label wifi_signal_strength_field;

    private int row_count = 0;

    public SideBar (Backend.BusManager bus_manager) {
        Object (bus_manager: bus_manager);

        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        this.column_spacing = 12;
        this.row_spacing = 12;

        add_headline_label ("Ressourcen");

        cpu_load_field = add_field_label ("CPU-Auslastung");
        memory_usage_field = add_field_label ("RAM-Belegung");
        free_drive_space_field = add_field_label ("Freier Speicher");

        add_headline_label ("Netzwerklast");

        net_load_in_field = add_field_label ("Eingehend");
        net_load_out_field = add_field_label ("Ausgehend");

        add_headline_label ("WLAN");

        wifi_ssid_field = add_field_label ("SSID");
        wifi_signal_strength_field = add_field_label ("Signalstärke");
    }

    private Gtk.Label add_headline_label (string headline) {
        Gtk.Label headline_label = new Gtk.Label (headline);
        headline_label.get_style_context ().add_class (Granite.StyleClass.H2_TEXT);
        headline_label.halign = Gtk.Align.START;
        headline_label.margin_top = 6;
        headline_label.margin_start = 12;
        headline_label.margin_end = 140;

        this.attach (headline_label, 0, row_count++, 2, 1);

        return headline_label;
    }

    private Gtk.Label add_field_label (string field_name) {
        Gtk.Label field_name_label = new Gtk.Label (field_name);
        field_name_label.get_style_context ().add_class (Granite.StyleClass.H3_TEXT);
        field_name_label.halign = Gtk.Align.START;
        field_name_label.margin_start = 24;

        Gtk.Label field_content_label = new Gtk.Label ("-");
        field_content_label.get_style_context ().add_class (Granite.StyleClass.H3_TEXT);
        field_content_label.halign = Gtk.Align.START;
        field_content_label.margin_end = 24;

        this.attach (field_name_label, 0, row_count, 1, 1);
        this.attach (field_content_label, 1, row_count++, 1, 1);

        return field_content_label;
    }

    private void connect_signals () {
        /* Kleiner Hack um Sicherzustellen, dass das Widget beim ersten Öffnen korrekt geladen wird. */
        this.notify["visible"].connect (() => {
            if (this.get_visible ()) {
                this.set_no_show_all (false);
                this.show_all ();
            }
        });

        bus_manager.wifi_ssid_changed.connect ((ssid) => {
            wifi_ssid_field.set_text (ssid);
        });

        bus_manager.wifi_signal_strength_changed.connect ((signal_strength) => {
            wifi_signal_strength_field.set_text (signal_strength > 0 ? "%u %%".printf (signal_strength) : "-");
        });

        bus_manager.cpu_load_changed.connect ((cpu_load) => {
            cpu_load_field.set_text ("%f %%".printf (cpu_load));
        });

        bus_manager.memory_usage_changed.connect ((memory_usage) => {
            memory_usage_field.set_text ("%f MB".printf (memory_usage));
        });

        bus_manager.net_load_changed.connect ((bytes_in, bytes_out) => {
            net_load_in_field.set_text ("%s/s".printf (format_size (bytes_in)));
            net_load_out_field.set_text ("%s/s".printf (format_size (bytes_out)));
        });

        bus_manager.free_drive_space_changed.connect ((megabytes) => {
            free_drive_space_field.set_text ("%i MB".printf (megabytes));
        });
    }
}