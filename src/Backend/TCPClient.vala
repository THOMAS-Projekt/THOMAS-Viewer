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
		private DataInputStream data_input_stream;
		private OutputStream output_stream;

		// Problem mit der Verbindung
		public signal void connection_error ();

		// Telemtrie-Daten erhalten
		public signal void telemetry_data_received (uint field_id, string content);

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
							data_input_stream = new DataInputStream (stream.input_stream);
							output_stream = stream.output_stream;

							// Empfangsthread starten
							new Thread<int> (null, () => {
								// Fehler abfangen
								try {
									// Schleife solange die Verbindung besteht
									while (connected) {
										// Kommandobyte lesen
										var cmd = data_input_stream.read_byte ();

										// Kommando analysieren
										switch (cmd) {
											// Antwort auf eine Telemetrie-Daten-Anfrage
											case 1:
												// ID empfangen
												var field_id = data_input_stream.read_byte ();

												// Neuen Status-Text empfangen (Lesen bis zum Zeilenende)
												var content = data_input_stream.read_line ();

												// Lesen erfolgreich?
												if (content != null) {
													// Ja => Ereignis auslösen
													telemetry_data_received (field_id, content);
												}

												// Fertig!
												break;

											// Ungültig
											default:
												// Meldung
												warning ("Ungültiges Kommandobyte \"%d\"", (int)cmd);

												// Fertig!
												break;
										}
									}
								} catch (Error e) {
									// Fehler-Nachricht abrufen
									var error_message = e.message;

									// Fehler (diesmal im Main-Thread um X-Server-Fehler zu vermeiden; Verhindert böse Überraschungen... :P)
									Idle.add (() => { show_error (error_message); return false; });
								}

								// Ende
								return 0;
							});
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
				// Port in zwei Bytes zerlegen
				uint8[] port = new uint8[2];
				port[0] = (UDP_SERVER_PORT >> 8);
				port[1] = (uint8)(UDP_SERVER_PORT & 0xff);

				// Daten senden
				output_stream.write ({1, port[0], port[1]});
			} catch (Error e) {
				// Fehler
				show_error (e.message);
			}
		}

		// Telemetrie-Daten anfragen
		public void request_telemetry_data (uint id) {
			// Fehler abfangen
			try {
				// Daten senden
				output_stream.write ({2, (uint8)id});
			} catch (Error e) {
				// Fehler
				show_error (e.message);
			}
		}

		// Bildqualität des Streams setzen
		public void send_image_quality (int image_size, int image_quality) {
			// Fehler abfangen
			try {
				// Werte validieren
				uint8 quality_value = image_quality < 0 ? 0 : (image_quality > 100 ? 100 : image_quality);
				uint8 size_value = image_size < 0 ? 0 : (image_size > 100 ? 100 : image_size);

				// Daten senden
				output_stream.write ({3, quality_value, size_value});
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
			// Verbindung beenden
			connected = false;

			// Verbindungsfehler
			connection_error ();

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
