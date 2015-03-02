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

		// Info-Button gedrückt.
		public signal void about_button_clicked ();

		// Instanzierung
		public TelemetryView () {
			// Kamera-Stream erstellen
			camera_stream = new CameraStream ();

			// Anfrage die Verbindung zu beenden
			camera_stream.disconnect_requested.connect (() => {
				// Verbindung beenden
				tcp_disconnect ();
			});

			// Der Info-Button wurde gedrückt
			camera_stream.about_button_clicked.connect (() => {
				// Info-Button gedrückt
				about_button_clicked ();
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
			this.pack2 (scrolled, false, false);
		}

		// Verbindung beenden
		public void tcp_disconnect (bool ?do_event = true) {
			// Ist der Client noch verbunden?
			if (viewer.Backend.TCPClient.connected) {
				// Ja => TCP-Verbindung beenden
				viewer.Backend.TCPClient.get_default ().close_connection ();
			}

			// UDP-Socket beenden
			camera_stream.stop_socket ();

			// Soll das Ereignis ausgelöst werden?
			if (do_event) {
				// Ja => Ereignis auslösen
				connection_closed ();
			}
		}

		// Socket starten
		public void run_stream_receiver () {
			// UDP-Socket erstellen
			camera_stream.run_socket ();
		}

		// Telemetrie-Empfänger starten
		public void run_telemetry_receiver () {
			// Telemetrie-Empfänger starten
			sensor_data.run_receiver ();
		}
	}
}
