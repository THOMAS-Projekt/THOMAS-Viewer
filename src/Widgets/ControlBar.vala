namespace viewer.Widgets {
	// Steuerungsleiste
	public class ControlBar : Gtk.Revealer {
		// Aktionen
		private Gtk.ActionBar actions;

		// Zurück-Button
		private Gtk.Button back_button;

		// Status-Label
		private Gtk.Label status_label;

		// Verbindung beenden
		public signal void disconnect_requested ();

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
