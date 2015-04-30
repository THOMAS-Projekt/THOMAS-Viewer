namespace viewer.Widgets {
	// Sensordaten
	public class SensorData : Gtk.Grid {
		// Anzahl an Zeilen
		private int rows = 0;

		// Start-Ereignis für die Timer
		private signal void start_updates ();

		// Instanzierung
		public SensorData () {
			// Abstände setzen
			this.row_spacing = 10;
			this.column_spacing = 12;

			// Abstand unten setzen
			this.margin_bottom = 12;

			// Einträge hinzufügen
			add_headline ("System");
			add_entry (0,	"Auslastung",	1000);
			add_entry (1,	"Speicher",		2000);
			add_entry (2,	"Festplatte",	10000);

			add_headline ("Netzwerk");
			add_entry (3,	"SSID",			4000);
			add_entry (4,	"Signalstärke",	1000);
			add_entry (5,	"Bandbreite",	1000);
		}

		// Empfänger starten
		public void run_receiver () {
			// Und los geht's!
			start_updates ();
		}

		// Überschrift hinzufügen
		private void add_headline (string text) {
			// Label erstellen
			var headline = new Gtk.Label (text);

			// Design-Klasse hinzufügen
			headline.get_style_context ().add_class ("h2");

			// Ausrichtung festlegen
			headline.halign = Gtk.Align.START;

			// Abstände definieren
			headline.margin_top = 6;
			headline.margin_start = 12;
			headline.margin_end = 140;

			// Label zur Liste hinzufügen
			this.attach (headline, 0, rows++, 3, 1);
		}

		// Eintrag hinzufügen
		private void add_entry (uint id, string field, uint update_interval) {
			// Labels erstellen
			var field_label = new Gtk.Label (field);
			var data_label = new Gtk.Label ("--");

			// Design-Klasse hinzufügen
			field_label.get_style_context ().add_class ("h3");
			data_label.get_style_context ().add_class ("h3");

			// Größenverhalten festlegen
			field_label.hexpand = false;
			data_label.hexpand = false;

			// Ausrichtung festlegen
			field_label.halign = Gtk.Align.START;
			data_label.halign = Gtk.Align.START;

			// Abstände definieren
			field_label.margin_start = 24;
			data_label.margin_end = 24;

			// Labels zur Liste hinzufügen
			this.attach (field_label, 0, rows, 1, 1);
			this.attach (data_label, 1, rows, 1, 1);

			// Lade-Anzeige erstellen
			var spinner = new Gtk.Spinner ();

			// Lade-Anzeige zur Liste hinzufügen
			this.attach (spinner, 2, rows++, 1, 1);

			// Auto-Updates starten
			start_updates.connect (() => {
				// Rückgabe-Ereignis setzen
				viewer.Backend.TCPClient.get_default ().telemetry_data_received.connect ((field_id, content) => {
					// Korrekte ID?
					if (field_id == id) {
						// Dieses Feld ist gemeint => Wert übernehmen
						data_label.label = content;

						// Lade-Anzeige stoppen
						spinner.stop ();
					}
				});

				// Timer erstellen
				Timeout.add (update_interval, () => {
					// Daten abfragen
					return run_request (spinner, data_label, id);
				});

				// Daten zu Beginn einmal abrufen
				run_request (spinner, data_label, id);
			});
		}

		// Führt eine Abfrage aus und verwaltet die Grafische Ausgabe entsprechend
		private bool run_request (Gtk.Spinner spinner, Gtk.Label data_label, uint id) {
			// Besteht die Verbindung noch?
			if (viewer.Backend.TCPClient.connected) {
				// Ja => Lade-Anzeige starten
				spinner.start ();

				// Neue Daten anfragen
				viewer.Backend.TCPClient.get_default ().request_telemetry_data (id);

				// Timer laufen lassen
				return true;
			} else {
				// Nein => Text zurücksetzen
				data_label.label = "--";

				// Lade-Anzeige stoppen
				spinner.stop ();

				// Timer stoppen
				return false;
			}
		}
	}
}
