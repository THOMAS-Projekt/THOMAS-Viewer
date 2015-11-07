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

public class Viewer.Application : Granite.Application {
    public MainWindow main_window;

    construct {
        program_name = "THOMAS-Viewer";
        exec_name = "thomas-viewer";

        build_data_dir = Constants.DATADIR;
        build_pkg_data_dir = Constants.PKGDATADIR;
        build_release_name = Constants.RELEASE_NAME;
        build_version = Constants.VERSION;
        build_version_info = Constants.VERSION_INFO;

        app_years = "2015";
        app_icon = "thomas-viewer";
        app_launcher = "thomas-viewer.desktop";
        application_id = "thomas.viewer";
        main_url = "https://github.com/THOMAS-Projekt/THOMAS-Viewer";
        bug_url = "https://github.com/THOMAS-Projekt/THOMAS-Viewer/issues";
        help_url = "https://github.com/THOMAS-Projekt/THOMAS-Viewer/wiki";
        translate_url = "https://github.com/THOMAS-Projekt/THOMAS-Viewer";
        about_authors = { "Marcus Wichelmann <admin@marcusw.de>" };
        about_documenters = { "Marcus Wichelmann <admin@marcusw.de>" };
        about_artists = { "Marcus Wichelmann <admin@marcusw.de>" };
        about_comments = "Zeigt die Telemetrie von THOMAS an.";
        about_translators = "";
    }

    public Application () {
        Granite.Services.Logger.initialize ("thomas-viewer");
    }

    public override void activate () {
        if (get_windows () == null) {
            main_window = new MainWindow (this);
            main_window.show_all ();
        } else {
            main_window.present ();
        }
    }

    public override void open (File[] files, string hint) {
        /* Vorerst nichts tun. */
    }

    public static void main (string[] args) {
        if (!Thread.supported ()) {
            error ("Multi-Threading wird möglicherweise nicht unterstützt.");
        }

        var application = new Viewer.Application ();
        application.run (args);
    }
}