namespace viewer.Widgets {
	// Telemetrie-Seite
	public class TelemetryView : Gtk.Paned {
		// Kamera-Stream
		private CameraStream camera_stream;

		// Scrollbarer Bereich
		private Gtk.ScrolledWindow scrolled;

		// Sensordaten-Anzeige
		private SensorData sensor_data;

		// Verbindung beendet
		public signal void connection_closed ();

		// Instanzierung
		public TelemetryView () {
			// Kamera-Stream erstellen
			camera_stream = new CameraStream ();

			// Anfrage die Verbindung zu beenden
			camera_stream.disconnect_requested.connect (() => {
				// Verbindung beenden
				tcp_disconnect ();
			});

			// Kamera-Stream auf der linken Seite anzeigen
			this.pack1 (camera_stream, true, false);

			// Scrollbaren Bereich erstellen
			scrolled = new Gtk.ScrolledWindow (null, null);

			// Verhalten anpassen
			scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;

			// Sensordaten-Anzeige erstellen
			sensor_data = new SensorData ();

			// Sensordaten-Anzeige zum scrollbaren Bereich hinzufügen
			scrolled.add (sensor_data);

			// Scrollbaren Bereich auf der rechten Seite anzeigen
			this.pack2 (scrolled, true, false);
		}

		// Verbindung beenden
		private void tcp_disconnect () {
			// TODO: Verbindung beenden

			// Verbindung beendet
			connection_closed ();
		}
	}
}
