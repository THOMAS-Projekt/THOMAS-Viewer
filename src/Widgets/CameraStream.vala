namespace viewer.Widgets {
	// Kamera-Stream
	public class CameraStream : Gtk.Overlay {
		// Kamerabild
		private Gtk.Image image;

		// Steuerungsleiste
		private ControlBar control_bar;

		// Instanzierung
		public CameraStream () {
			// Mindestbreite setzen
			this.set_size_request (400, -1);

			// Kamerabild erstellen
			image = new Gtk.Image ();

/*
	// Experiment! Dies muss später zusammen mit einem korrekten Error-Handling implementiert werden.
	var file = File.new_for_path ("/home/marcus/THOMAS-Projekt/test.jpeg");
	var input = file.read ();
	var pixbuf = new Gdk.Pixbuf.from_stream (input);
	image.pixbuf = pixbuf;
*/

			// Kamerabild anzeigen
			this.add_overlay (image);

			// Steuerungsleiste erstellen
			control_bar = new ControlBar ();

			// Steuerungsleiste anzeigen
			this.add_overlay (control_bar);
		}
	}
}
