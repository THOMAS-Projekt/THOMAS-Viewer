namespace viewer.Backend {
	// TCP-Client
	public class TCPClient : Object {
		// Aktuelle Instanz
		public static TCPClient? client = null;

		// Gibt an ob eine aktive Verbindung besteht
		public static bool connected = false;

		// Der Socket
		private SocketClient? socket = null;

		// IO-Stream
		private SocketConnection? stream = null;

		// Daten-Streams
		private DataInputStream input_stream;
		private DataOutputStream output_stream;

		// Instanzierung
		public TCPClient (string hostname) {
			// Fehler abfangen
			try {
				// Adressen-Resolver abrufen
				var resolver = Resolver.get_default ();

				// Nach Adressen suchen
				var addresses = resolver.lookup_by_name (hostname);

				// Mindestens eine Adresse gefunden?
				if (addresses.length () > 0) {
					// Ja => Erste Adresse verwenden
					var address = new InetSocketAddress (addresses.nth_data (0), TCP_CLIENT_PORT);

					// Socket erstellen
					socket = new SocketClient ();

					// Erfolgreich erstellt?
					if (socket != null) {
						// Ja => Verbindung herstellen
						stream = socket.connect (address);

						// Erfolgreich verbunden?
						if (stream != null) {
							// Verbindung erfolgreich => Verbunden.
							connected = true;

							// Streams abrufen
							input_stream = new DataInputStream (stream.input_stream);
							output_stream = new DataOutputStream (stream.output_stream);
						} else {
							// Verbindung fehlgeschlagen => Fehler
							show_error ("Verbinden zu \"%s\" fehlgeschlagen.".printf (hostname));
						}
					} else {
						// Nein => Fehler
						show_error ("Erstellen des TCP-Sockets fehlgeschlagen!");
					}
				} else {
					// Nein => Fehler
					show_error ("Die Adresse \"%s\" konnte nicht gefunden werden.".printf (hostname));
				}
			} catch (Error e) {
				// Fehler
				show_error (e.message);
			}
		}

		// Anfrage zum Beginn der Übertragung
		public void send_udp_ready () {
			// Fehler abfangen
			try {
				// Kommandobyte senden
				connected = output_stream.put_byte (1);

				// UDP-Port senden
				connected = output_stream.put_uint16 (UDP_SERVER_PORT);
			} catch (Error e) {
				// Fehler
				show_error (e.message);
			}
		}

		// Verbindung beenden
		public void close_connection () {
			// Verbindung beenden
			connected = false;

			// Fehler abfangen
			try {
				// Socket schließen
				stream.get_socket ().close ();
			} catch (Error e) {
				// Fehler
				show_error (e.message);
			}
		}

		// Fehlermeldung ausgeben
		private void show_error (string message) {
			// Konsolen-Ausgabe
			debug ("Fehler: %s", message);

			// Info-Dialog erstellen
			var dialog = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, "Fehler: %s".printf(message));

			// Rückgabe-Ereignis nutzen
			dialog.response.connect (() => {
				// Dialog schließen
				dialog.destroy();
			});

			// Dioalog anzeigen
			dialog.show ();
		}

		// Instanz abrufen
		public static TCPClient get_default () {
			// Bereits instanziert? Noch aktuell?
			if (client == null || !connected) {
				// Nein => Verbindung getrennt.
				connected = false;

				// Neuen Clienten erstellen und gespeicherte Adresse verwenden
				client = new TCPClient (SettingsManager.get_default ().last_host);
			}

			// Instanz zurückgeben
			return client;
		}
	}
}
