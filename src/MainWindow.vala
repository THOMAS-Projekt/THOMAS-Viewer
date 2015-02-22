namespace viewer {
	// Hauptfenster
	public class MainWindow : Gtk.Window {
		// Anwendung
		private viewerApp app;

		// Headerbar
		private Gtk.HeaderBar header_bar;

		// Stack
		private Gtk.Stack stack;

		// Willkommensbildschirm
		private Granite.Widgets.Welcome welcome;

		// Telemetrie-Seite
		private Widgets.TelemetryView telemetry_view;

		// Instanzierung
		public MainWindow (viewerApp app) {
			// Anwendung setzen
			this.app = app;
			this.set_application (app);

			// Dunkles Theme verwenden
			Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

			// Fenstergröße setzen
			this.set_default_size (1000, 600);

			// Fensterposition setzen
			this.window_position = Gtk.WindowPosition.CENTER;

			// Headerbar erstellen
			header_bar = new Gtk.HeaderBar ();

			// Fenstertitel setzen
			header_bar.title = "THOMAS-Viewer";

			// Schließen-Button anzeigen
			header_bar.show_close_button = true;

			// "header-bar"-Klasse vom Objekt entfernen
			header_bar.get_style_context ().remove_class ("header-bar");

			// Headerbar als Titelleiste setzen
			this.set_titlebar (header_bar);

			// Stack erstellen
			stack = new Gtk.Stack ();

			// Animationsgeschwindigkeit setzen
			stack.transition_duration = 400;

			// Willkommensbildschirm erstellen
			welcome = new Granite.Widgets.Welcome ("Nicht verbunden", "Bitte wähle eine Adresse");

			// Buttons zum Willkommensbildschirm hinzufügen
			welcome.append ("edit", "Adresse eingeben", "Eine neue Adresse eingeben");
			welcome.append ("media-playback-start", "Verbindung wiederherstellen", "Mit der zuletzt verwendeten Adresse verbinden");

			// Click-Ereignis des Willkommensbildschirmes setzen
			welcome.activated.connect ((index) => {
				// Welcher Button wurde gedrückt?
				if (index == 0) {
					// Adresse eingeben => TODO: Eingabe-Dialog anzeigen

					// Telemetrie-Seite anzeigen
					stack.set_visible_child_full ("telemetry", Gtk.StackTransitionType.SLIDE_LEFT);
				}
			});

			// Willkommensbildschirm zum Stack hinzufügen
			stack.add_named (welcome, "welcome");

			// Telemetrie-Seite erstellen
			telemetry_view = new Widgets.TelemetryView ();

			// Verbindung wurde beendet
			telemetry_view.connection_closed.connect (() => {
				// Zurück zur Startseite
				stack.set_visible_child_full ("welcome", Gtk.StackTransitionType.SLIDE_RIGHT);
			});

			// Telemetrie-Seite zum Stack hinzufügen
			stack.add_named (telemetry_view, "telemetry");

			// Stack zum Fenster hinzufügen
			this.add (stack);

			// Alles anzeigen
			this.show_all ();
		}
	}
}
