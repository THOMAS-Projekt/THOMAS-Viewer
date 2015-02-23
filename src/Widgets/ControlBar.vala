namespace viewer.Widgets {
	// Steuerungsleiste
	public class ControlBar : Gtk.Revealer {
		// Aktionen
		private Gtk.ActionBar actions;

		// Zurück-Button
		private Gtk.Button back_button;

		// Status-Label
		private Gtk.Label status_label;

		// Info-Button
		private Gtk.Button about_button;

		// Einstellungs-Button
		private Gtk.Button settings_button;

		// Gibt an ob die Einstellungen gerade angezeigt werden
		public bool settings_popover_active { get; private set; default = false; }

		// Verbindung beenden
		public signal void disconnect_requested ();

		// Info-Button gedrückt.
		public signal void about_button_clicked ();

		// Instanzierung
		public ControlBar () {
			// Animation setzen
			this.transition_type = Gtk.RevealerTransitionType.CROSSFADE;

			// Aktionsleiste erstellen
			actions = new Gtk.ActionBar ();

			// Größenverhalten der Aktionsleiste setzen
			actions.vexpand = false;

			// Aktionsleiste unten positionieren
			actions.valign = Gtk.Align.END;

			// Transparenz der Aktionsleiste setzen
			actions.opacity = 0.9;

			// Zurück-Button erstellen
			back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.BUTTON);

			// Click-Ereignis setzen
			back_button.clicked.connect (() => {
				// Verbindung beenden
				disconnect_requested ();
			});

			// Zurück-Button zur Leiste hinzufügen
			actions.pack_start (back_button);

			// Status-Label erstellen
			status_label = new Gtk.Label ("");

			// Status-Label zur Leiste hinzufügen
			actions.set_center_widget (status_label);

			// Info-Button erstellen
			about_button = new Gtk.Button.from_icon_name ("help-info-symbolic", Gtk.IconSize.BUTTON);

			// Click-Ereignis setzen
			about_button.clicked.connect (() => {
				// Info-Dialog anzeigen
				about_button_clicked ();
			});

			// Info-Button zur Leiste hinzufügen
			actions.pack_end (about_button);

			// Einstellungs-Button erstellen
			settings_button = new Gtk.Button.from_icon_name ("media-eq-symbolic", Gtk.IconSize.BUTTON);

			// Click-Ereignis setzen
			settings_button.clicked.connect (() => {
				// Popover erstellen
				var popover = new Gtk.Popover (settings_button);

				// Popover wird geschlossen
				popover.closed.connect (() => {
					// Einstellungs-Popover wird nicht mehr angezeigt
					settings_popover_active = false;
				});

				// Einstellungs-Popover wird angezeigt
				settings_popover_active = true;

				// Einstellungstabelle erstellen
				var properties = new Properties ();

				// Einstellungstabelle im Popover anzeigen
				popover.add (properties);

				// Popover anzeigen
				popover.show_all ();
			});

			// Einstellungs-Button zur Leiste hinzufügen
			actions.pack_end (settings_button);

			// Aktionsleiste hinzufügen
			this.add (actions);
		}

		// Status-Text ändern
		public void set_status (string status) {
			// Text des Status-Labels überschreiben
			status_label.label = status;
		}
	}
}
