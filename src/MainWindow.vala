namespace viewer {
	// Hauptfenster
	public class MainWindow : Gtk.Window {
		// Anwendung
		private viewerApp app;

		// Vollbildmodus aktiv?
		private bool fullscreened = false;

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

			// Tastendruck
			this.key_press_event.connect ((event) => {
				// Taste analysieren
				switch (event.keyval) {
					// F11
					case Gdk.Key.F11:
						// Bereits im Vollbildmodus?
						if (!fullscreened) {
							// Nein => Vollbildmodus starten
							this.fullscreen ();
							fullscreened = true;
						} else {
							// Ja => Vollbildmodus beenden
							this.unfullscreen ();
							fullscreened = false;
						}

						// Fertig!
						break;

					// Escape
					case Gdk.Key.Escape:
						// Vollbildmodus aktiv?
						if (fullscreened) {
							// Ja => Vollbildmodus beenden
							this.unfullscreen ();
							fullscreened = false;
						}

						// Fertig!
						break;
				}

				// Fertig!
				return true;
			});

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
			welcome.append ("media-playback-start", "Verbindung wiederherstellen", "Mit \"%s\" verbinden".printf (SettingsManager.get_default ().last_host));

			// Click-Ereignis des Willkommensbildschirmes setzen
			welcome.activated.connect ((index) => {
				// Soll die Adresse vorm Verbinden aktualisiert werden?
				if (index == 0) {
					// Ja => TODO: Eingabe-Dialog anzeigen und adresse setzten
				}

				// TCP-Verbindung herstellen
				viewer.Backend.TCPClient.get_default ();

				// Erfolgreich verbunden?
				if (viewer.Backend.TCPClient.connected) {
					// Ja => Telemetrie-Seite anzeigen
					stack.set_visible_child_full ("telemetry", Gtk.StackTransitionType.SLIDE_LEFT);

					// Kamera-Stream-Empfänger starten
					telemetry_view.run_stream_receiver ();
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

			// Der Info-Button wurde gedrückt
			telemetry_view.about_button_clicked.connect (() => {
				// Info-Dialog anzeigen
				app.show_about (this);
			});

			// Telemetrie-Seite zum Stack hinzufügen
			stack.add_named (telemetry_view, "telemetry");

			// Stack zum Fenster hinzufügen
			this.add (stack);

			// Fenster wird geschlossen
			this.destroy.connect (() => {
				// Besteht eine Verbindung?
				if (viewer.Backend.TCPClient.connected) {
					// Ja => TCP-Server beenden
					telemetry_view.tcp_disconnect (false);
				}
			});

			// Alles anzeigen
			this.show_all ();
		}
	}
}
