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

		// Instanzierung
		public MainWindow (viewerApp app) {
			// Anwendung setzen
			this.app = app;
			this.set_application (app);

			// Dunkles Theme verwenden
			Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

			// Fenstergröße setzen
			this.set_size_request (1000, 600);

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

			// Willkommensbildschirm erstellen
			welcome = new Granite.Widgets.Welcome ("Nicht verbunden", "Bitte wähle eine Adresse");

			// Buttons zum Willkommensbildschirm hinzufügen
			welcome.append ("edit", "Adresse eingeben", "Eine neue Adresse eingeben");
			welcome.append ("media-playback-start", "Verbindung wiederherstellen", "Mit der zuletzt verwendeten Adresse verbinden");

			// Willkommensbildschirm zum Stack hinzufügen
			stack.add_named (welcome, "welcome");

			// Stack zum Fenster hinzufügen
			this.add (stack);

			// Alles anzeigen
			this.show_all ();
		}
	}
}
