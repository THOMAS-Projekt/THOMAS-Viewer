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

public class Viewer.Widgets.MapsPage : Gtk.Stack {
    public Backend.BusManager bus_manager { private get; construct; }

    private Granite.Widgets.Welcome welcome_screen;
    private Granite.Widgets.DynamicNotebook notebook;

    public MapsPage (Backend.BusManager bus_manager) {
        Object (bus_manager: bus_manager);

        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        welcome_screen = new Granite.Widgets.Welcome ("Keine Karten geöffnet", "Starte neue Scanvorgänge um Karten zu laden.");
        welcome_screen.append ("add", "Neuen Scanvorgang starten", "Einen neuen Scan durchführen und die Karte hier öffnen.");

        notebook = new Granite.Widgets.DynamicNotebook ();
        notebook.add_button_visible = true;

        this.add_named (welcome_screen, "welcome-screen");
        this.add_named (notebook, "notebook");
    }

    private void connect_signals () {
        welcome_screen.activated.connect ((index) => {
            if (index == 0) {
                start_new_scan ();
            }
        });

        notebook.new_tab_requested.connect (start_new_scan);
    }

    private void start_new_scan () {
        bus_manager.start_new_scan.begin ((obj, res) => {
            int map_id = bus_manager.start_new_scan.end (res);

            if (map_id < 0) {
                return;
            }

            MapTab map_tab = new MapTab ("Karte %i".printf (map_id));

            notebook.insert_tab (map_tab, -1);

            this.set_visible_child_name ("notebook");
        });
    }
}