namespace viewer.Widgets {
	// Kamera-Stream
	public class CameraStream : Gtk.Overlay {
		// Kamerabild
		private Gtk.Image image;

		// Steuerungsleiste
		private ControlBar control_bar;

		// Verbindung beenden
		public signal void disconnect_requested ();

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

			// Anfrage die Verbindung zu beenden
			control_bar.disconnect_requested.connect (() => {
				// Verbindung beenden
				disconnect_requested ();
			});

			// Steuerungsleiste anzeigen
			this.add_overlay (control_bar);

			// Zu überwachende Ereignisse festlegen
			this.events |= Gdk.EventMask.POINTER_MOTION_MASK;
			this.events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
			this.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

			// Die Maus wird auf das Objekt bewegt
			this.enter_notify_event.connect ((event) => {
				// Steuerungsleiste anzeigen
				control_bar.set_reveal_child(true);

				// Fertig!
				return false;
			});

			// Die Maus verlässt das Objekt
			this.leave_notify_event.connect ((event) => {
				// Steuerungsleiste verstecken
				control_bar.set_reveal_child(false);

				// Fertig!
				return false;
			});
		}
	}
}
