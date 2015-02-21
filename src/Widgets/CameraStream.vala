namespace viewer.Widgets {
	// Kamera-Stream
	public class CameraStream : Gtk.Overlay {
		// Kamerabild
		private Gtk.Image image;

		// Instanzierung
		public CameraStream () {
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
		}
	}
}
