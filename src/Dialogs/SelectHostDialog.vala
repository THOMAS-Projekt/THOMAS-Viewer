namespace viewer.Dialogs {
	// Server-Auswahl-Dialog
	public class SelectHostDialog : Gtk.Dialog {
		// Tabelle
		private Gtk.Grid grid;

		// Bild
		private Gtk.Image image;

		// Titel
		private Gtk.Label headline;

		// Eingabefeld
		private Gtk.Entry entry;

		// Verbinden-Button
		private Gtk.Button connect_button;

		// Instanzierung
		public SelectHostDialog () {
			// Schließen-Button verstecken
			this.deletable = false;

			// Tabelle erstellen
			grid = new Gtk.Grid ();

			// Abstände setzen
			grid.margin_start = 12;
			grid.margin_end = 6;
			grid.margin_bottom = 12;
			grid.column_spacing = 24;
			grid.row_spacing = 6;

			// Bild erstellen
			image = new Gtk.Image.from_icon_name ("edit", Gtk.IconSize.DIALOG);

			// Ausrichtung setzen
			image.valign = Gtk.Align.START;

			// Zur Tabelle hinzufügen
			grid.attach (image, 0, 0, 1 ,2);

			// Titel erstellen
			headline = new Gtk.Label ("<b>Eigene Adresse wählen</b>");

			// Markup verwenden
			headline.use_markup = true;

			// Design-Klasse setzen
			headline.get_style_context ().add_class ("h3");

			// Ausrichtung setzen
			headline.halign = Gtk.Align.START;
			headline.valign = Gtk.Align.START;

			// Zur Tabelle hinzufügen
			grid.attach (headline, 1, 0, 1 ,1);

			// Eingabefeld erstellen
			entry = new Gtk.Entry ();

			// Platzhalter setzen
			entry.placeholder_text = SettingsManager.get_default ().last_host;

			// Größe setzen
			entry.set_size_request (300, -1);

			// Zur Tabelle hinzufügen
			grid.attach (entry, 1, 1, 1 ,1);

			// Tabelle zum Dialog hinzufügen
			this.get_content_area ().add (grid);

			// Verbinden-Button erstellen
			connect_button = this.add_button ("Verbinden", Gtk.ResponseType.APPLY) as Gtk.Button;

			// Design-Klasse setzen
			connect_button.get_style_context ().add_class ("suggested-action");

			// Verbinden-Button fokussieren
			connect_button.has_focus = true;

			// Rückgabe-Ereignis setzen
			this.response.connect (() => {
				// Adresse eingegeben?
				if (entry.text != "") {
					// Ja => Adresse speichern
					SettingsManager.get_default ().last_host = entry.text;
				}
			});

			// Alles anzeigen
			this.show_all ();
		}
	}
}
