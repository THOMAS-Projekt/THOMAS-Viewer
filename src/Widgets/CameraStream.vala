namespace viewer.Widgets {
	// Kamera-Stream
	public class CameraStream : Gtk.Overlay {
		// Kamerabild
		private Gtk.Image image;

		// Steuerungsleiste
		private ControlBar control_bar;

		// UDP-Socket
		private Socket socket;

		// Datenquelle
		private SocketSource socket_source;

		// Cancel-Objekt
		private Cancellable cancellable;

		// Main-Loop
		private MainLoop main_loop;

		// Anzahl der in dieser Sekunde empfangenen Frames
		private int frames_per_second = 0;

		// Anzahl der in dieser Sekunde empfangenen Bits
		private uint64 bits_per_second;

		// Gibt an ob der UDP-Socket läuft
		private bool udp_running = false;

		// Verbindung beenden
		public signal void disconnect_requested ();

		// Info-Button gedrückt.
		public signal void about_button_clicked ();

		// Instanzierung
		public CameraStream () {
			// Mindestbreite setzen
			this.set_size_request (400, -1);

			// Kamerabild erstellen
			image = new Gtk.Image ();

			// Kamerabild anzeigen
			this.add_overlay (image);

			// Steuerungsleiste erstellen
			control_bar = new ControlBar ();

			// Anfrage die Verbindung zu beenden
			control_bar.disconnect_requested.connect (() => {
				// Verbindung beenden
				disconnect_requested ();
			});

			// Der Info-Button wurde gedrückt
			control_bar.about_button_clicked.connect (() => {
				// Info-Button gedrückt
				about_button_clicked ();
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

		// Socket erstellen
		public void run_socket (uint16 port) {
			// Fehler abfangen
			try {
				// Statusmeldung
				control_bar.set_status ("UDP-Socket wird erstellt...");

				// Mess-Variablen zurücksetzen
				frames_per_second = 0;
				bits_per_second = 0;

				// Cancel-Objekt erstellen
				cancellable = new Cancellable ();

				// UDP-Socket erstellen
				socket = new Socket (SocketFamily.IPV4, SocketType.DATAGRAM, SocketProtocol.UDP);

				// Port festlegen
				socket.bind (new InetSocketAddress (new InetAddress.loopback (SocketFamily.IPV4), port), true);

				// Datenquelle erstellen
				socket_source = socket.create_source (IOCondition.IN, cancellable);

				// Empfangsfunktion festlegen
				socket_source.set_callback ((socket, condition) => {
					// Fehler abfangen
					try {
						// Puffer erstellen
						uint8 buffer[102400];

						// Empfangene Daten in den Puffer schreiben und Länge prüfen
						var received = socket.receive (buffer);

						if (received >= buffer.length) {
							// Puffer zu klein => Fehler
							control_bar.set_status ("Die empfangenen Daten überschreiten die Puffergröße von %s.".printf (format_size (buffer.length)));
						} else {
							// Alles gut => Frame anzeigen
							show_frame_from_data (buffer);
						}

						// FPS hochzählen
						frames_per_second++;

						// Bits hochzählen
						bits_per_second += received * 8;
					} catch (Error e) {
						// Fehler
						control_bar.set_status (e.message);
					}

					// Datenquelle nicht löschen
					return true;
				});

				// Mit der Hauptschleife verknüpfen
				socket_source.attach (MainContext.default ());

				// TODO: Befehl zum Starten der Übertragung senden und dem Server den Port mitteilen

				// Socket gestartet
				udp_running = true;

				// FPS-Timer erstellen
				Timeout.add (1000, () => {
					// Nur um sicher zu gehen...
					if (image.pixbuf != null) {
						// Bild vorhanden => Status aktualisieren
						control_bar.set_status ("%dx%d -- %d FPS (%s)".printf (image.pixbuf.width, image.pixbuf.height, frames_per_second, format_speed (bits_per_second)));

						// FPS zurücksetzen
						frames_per_second = 0;

						// Bits zurücksetzen
						bits_per_second = 0;
					}

					// Timer weiterlaufen lassen solange der Socket läuft
					return udp_running;
				});

				// Statusmeldung
				control_bar.set_status ("Warte auf Übertragung...");

				// Hauptschleife erstellen
				main_loop = new MainLoop ();

				// Hauptschleife starten
				main_loop.run ();
			} catch (Error e) {
				// Fehler
				control_bar.set_status (e.message);
			}
		}

		// Socket stoppen
		public void stop_socket () {
			// UDP-Socket beendet
			udp_running = false;

			// Cancel
			cancellable.cancel ();

			// Verknüpfung zur Hauptschleife auflösen (Sonst wird die Schleife nicht beendet.)
			socket_source.destroy ();

			// Hauptschleife beenden
			main_loop.quit ();

			// Statusmeldung
			control_bar.set_status ("UDP-Socket gestoppt.");

			// Aktuelles Bild löschen
			image.pixbuf = null;
		}

		// Frame-Daten als Bild darstellen
		private void show_frame_from_data (uint8[] data) {
			// Fehler abfangen
			try {
				// Jpeg-Decoder erstellen
				var loader = new Gdk.PixbufLoader ();

				// Daten übergeben
				loader.write (data);

				// Daten vollständig
				loader.close ();

				// Bild abrufen
				var pixbuf = loader.get_pixbuf ();

				// Bild anzeigen
				image.pixbuf = pixbuf;
			} catch (Error e) {
				// Fehler
				control_bar.set_status (e.message);
			}
		}

		// Geschwindigkeit formatiert ausgeben
		private string format_speed (uint64 bits) {
			// Wert aufteilen
			var TBit = (bits >> 40);
			var GBit = (bits >> 30) & 0x03FF;
			var MBit = (bits >> 20) & 0x03FF;
			var KBit = (bits >> 10) & 0x03FF;
			var Bit = bits & 0x03FF;

			// Wert geeignet darstellen
			var description = (TBit > 0 ? @"$TBit TBit/s und $GBit GBit/s" :
					(GBit > 0 ? @"$GBit GBit/s und $MBit MBit/" :
					(MBit > 0 ? @"$MBit MBit/s und $KBit KBit/s" :
					(KBit > 0 ? @"$KBit KBit/s und $Bit Bit/s" :
					(Bit > 0 ? @"$Bit Bit/s" : "")))));

			// Beschreibung zurückgeben
			return description;
		}
	}
}
