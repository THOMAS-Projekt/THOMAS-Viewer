namespace viewer.Widgets {
	// Sensordaten
	public class SensorData : Gtk.Grid {
		// Anzahl an Zeilen
		private int rows = 0;

		// Instanzierung
		public SensorData () {
			// Abstände setzen
			this.row_spacing = 10;
			this.column_spacing = 12;

			// Abstand unten setzen
			this.margin_bottom = 12;

// Beispieleinträge
add_headline ("System");
add_entry ("Auslastung", "30 %");
add_entry ("Speicher", "70 MB");
add_entry ("/dev/sda1", "3,3 GB");
add_headline ("Netzwerk");
add_entry ("SSID", "Thomas-Projekt");
add_entry ("Signalstärke", "70 %");
add_entry ("Bandbreite", "30 Mbit/s");
add_headline ("Ultraschall");
add_entry ("Vorne Links", "131 cm");
add_entry ("Vorne Mitte", "124 cm");
add_entry ("Vorne Rechts", "145 cm");
add_entry ("Hinten Links", "47 cm");
add_entry ("Hinten Rechts", "23 cm");

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
			headline.margin_end = 40;

			// Label zur Liste hinzufügen
			this.attach (headline, 0, rows++, 2, 1);
		}

		// Eintrag hinzufügen
		private void add_entry (string field, string data) {
			// Labels erstellen
			var field_label = new Gtk.Label (field);
			var data_label = new Gtk.Label (data);

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
			this.attach (data_label, 1, rows++, 1, 1);
		}
	}
}
