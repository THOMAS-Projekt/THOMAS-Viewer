namespace viewer.Widgets {
	// Telemetrie-Seite
	public class TelemetryView : Gtk.Paned {
		// Kamera-Stream
		private CameraStream camera_stream;

		// Instanzierung
		public TelemetryView () {
			// Kamera-Stream erstellen
			camera_stream = new CameraStream ();

			// Kamera-Stream auf der linken Seite anzeigen
			this.add1 (camera_stream);
		}
	}
}
