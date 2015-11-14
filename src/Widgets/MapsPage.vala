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

    private Gee.HashMap<int, MapTab> maps;

    public MapsPage (Backend.BusManager bus_manager) {
        Object (bus_manager: bus_manager);

        maps = new Gee.HashMap<int, MapTab> ();

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
        bus_manager.map_scan_continued.connect ((map_id, angle, distances) => {
            if (!maps.has_key (map_id)) {
                return;
            }

            maps.@get (map_id).add_distances (angle, distances);
        });

        bus_manager.map_scan_finished.connect ((map_id) => {
            if (!maps.has_key (map_id)) {
                return;
            }

            maps.@get (map_id).working = false;
        });

        welcome_screen.activated.connect ((index) => {
            if (index == 0) {
                start_new_scan ();
            }
        });

        notebook.new_tab_requested.connect (start_new_scan);
        notebook.tab_removed.connect ((tab) => {
            MapTab? map_tab = (tab as MapTab);

            if (map_tab == null) {
                return;
            }

            bus_manager.stop_scan (map_tab.map_id);
            maps.unset (map_tab.map_id);
        });
    }

    private void start_new_scan () {
        bus_manager.start_new_scan.begin ((obj, res) => {
            int map_id = bus_manager.start_new_scan.end (res);

            if (map_id < 0) {
                return;
            }

            MapTab map_tab = new MapTab (map_id, "Karte %i".printf (map_id));
            map_tab.working = true;

            maps.@set (map_id, map_tab);
            notebook.insert_tab (map_tab, -1);

            this.set_visible_child_name ("notebook");
        });
    }
}