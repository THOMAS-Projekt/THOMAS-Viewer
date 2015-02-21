namespace viewer {
	// Hauptfenster
	public class MainWindow : Gtk.Window {
		// Anwendung
		public viewerApp app;

		// Instanzierung
		public MainWindow (viewerApp app) {
			// Anwendung setzen
			this.app = app;
			this.set_application (app);

			// Dunkles Theme verwenden
			Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

			// Fenstergröße setzen
			this.set_size_request (1000, 600);

			// Resize-Grip verstecken
			this.has_resize_grip = false;

			// Fensterposition setzen
			this.window_position = Gtk.WindowPosition.CENTER;

this.add (new Gtk.Label ("TODO"));

			// Alles anzeigen
			this.show_all ();
		}
	}
}
