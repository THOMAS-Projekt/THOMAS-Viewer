namespace viewer {
	// Ports
	const uint16 TCP_CLIENT_PORT = 4223;
	const uint16 UDP_SERVER_PORT = 4222;

	// Anwendung
	public class viewerApp : Granite.Application {
		// Hauptfenster
		public MainWindow window;

		// Konstruktor
		construct {
			// Programmeigenschaften setzen
			program_name = "THOMAS-Viewer";
			exec_name = "thomas-viewer";

			// Konfigurationen übernehmen
			build_data_dir = Constants.DATADIR;
			build_pkg_data_dir = Constants.PKGDATADIR;
			build_release_name = Constants.RELEASE_NAME;
			build_version = Constants.VERSION;
			build_version_info = Constants.VERSION_INFO;

			// Weitere Eigenschaften
			app_years = "2015";
			app_icon = "thomas-viewer";
			app_launcher = "thomas-viewer.desktop";
			application_id = "thomas.viewer";
			main_url = "https://github.com/THOMAS-Projekt/THOMAS-Viewer";
			bug_url = "https://github.com/THOMAS-Projekt/THOMAS-Viewer/issues";
			help_url = "https://github.com/THOMAS-Projekt/THOMAS-Viewer/wiki";
			translate_url = "https://github.com/THOMAS-Projekt/THOMAS-Viewer";
			about_authors = {"Marcus Wichelmann <admin@marcusw.de>"};
			about_documenters = {"Marcus Wichelmann <admin@marcusw.de>"};
			about_artists = {"Marcus Wichelmann <admin@marcusw.de>"};
			about_comments = "Zeigt die Telemetrie von THOMAS an.";
			about_translators = "";
		}

		// Instanzierung
		public viewerApp () {
			// Logging initialisieren
			Granite.Services.Logger.initialize ("thomas-viewer");
			Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
		}

		// Aktivierung
		public override void activate () {
			// Fenster schon erstellt?
			if (get_windows () == null) {
				// Nein => Hauptfenster erstellen
				window = new MainWindow (this);

				// Hauptfenster anzeigen
				window.show_all ();
			} else {
				// Ja => Hauptfenster in den Vordergrund holen
				window.present ();
			}
		}

		// Mit diesem Programm wurden Dateien geöffnet
		public override void open (File [] files, string hint) {
			// Nichts tun
		}

		// Main-Funktion
		public static void main (string [] args) {
			// Anwendung instanzieren
			var app = new viewer.viewerApp ();

			// Und los!
			app.run (args);
		}
	}
}
