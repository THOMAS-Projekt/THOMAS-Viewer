namespace viewer.Widgets {
	// Einstellungen
	public class Properties : Gtk.Grid {
		// Auto-Resize
		private Gtk.Label auto_resize_label;
		private Gtk.Switch auto_resize_switch;

		// Bildgröße
		private Gtk.Label image_size_label;
		private Gtk.Scale image_size_scale;

		// Bildqualität
		private Gtk.Label image_quality_label;
		private Gtk.Scale image_quality_scale;

		// Instanzierung
		public Properties () {
			// Abstände definieren
			this.margin = 12;
			this.row_spacing = 12;
			this.column_spacing = 12;

			// Auto-Resize-Label erstellen
			auto_resize_label = new Gtk.Label ("Bild einpassen:");

			// Ausrichtung setzen
			auto_resize_label.hexpand = true;
			auto_resize_label.halign = Gtk.Align.END;

			// Zur Tabelle hinzufügen
			this.attach (auto_resize_label, 0, 0, 1, 1);

			// Auto-Resize-Switch erstellen
			auto_resize_switch = new Gtk.Switch ();

			// Mit Einstellung verknüpfen
			SettingsManager.get_default ().settings.bind ("auto-resize", auto_resize_switch, "active", SettingsBindFlags.DEFAULT);

			// Ausrichtung setzen
			auto_resize_switch.hexpand = false;
			auto_resize_switch.halign = Gtk.Align.START;

			// Zur Tabelle hinzufügen
			this.attach (auto_resize_switch, 1, 0, 1, 1);

			// Bildgrößen-Label erstellen
			image_size_label = new Gtk.Label ("Auflösung:");

			// Ausrichtung setzen
			image_size_label.hexpand = true;
			image_size_label.halign = Gtk.Align.END;

			// Zur Tabelle hinzufügen
			this.attach (image_size_label, 0, 1, 1, 1);

			// Bildgrößen-Slider erstellen
			image_size_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, new Gtk.Adjustment (SettingsManager.get_default ().image_size, 5, 100, 1, 10, 0));

			// Werte auf gerade Zahlen runden
			image_size_scale.digits = 0;

			// Größe festlegen
			image_size_scale.set_size_request (150, -1);

			// Werte nicht anzeigen
			image_size_scale.draw_value = false;

			// Ereignis verknüpfen
			image_size_scale.value_changed.connect (() => {
				// Server den neuen Wert mitteilen
				send_image_quality ();

				// Wert speichern
				SettingsManager.get_default ().image_size = (int)image_size_scale.get_value ();
			});

			// Zur Tabelle hinzufügen
			this.attach (image_size_scale, 1, 1, 1, 1);

			// Bildqualitäts-Label erstellen
			image_quality_label = new Gtk.Label ("Qualität:");

			// Ausrichtung setzen
			image_quality_label.hexpand = true;
			image_quality_label.halign = Gtk.Align.END;

			// Zur Tabelle hinzufügen
			this.attach (image_quality_label, 0, 2, 1, 1);

			// Bildqualitäts-Slider erstellen
			image_quality_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, new Gtk.Adjustment (SettingsManager.get_default ().image_quality, 5, 100, 1, 10, 0));

			// Werte auf gerade Zahlen runden
			image_quality_scale.digits = 0;

			// Größe festlegen
			image_quality_scale.set_size_request (150, -1);

			// Werte nicht anzeigen
			image_quality_scale.draw_value = false;

			// Ereignis verknüpfen
			image_quality_scale.value_changed.connect (() => {
				// Server den neuen Wert mitteilen
				send_image_quality ();

				// Wert speichern
				SettingsManager.get_default ().image_quality = (int)image_quality_scale.get_value ();
			});

			// Zur Tabelle hinzufügen
			this.attach (image_quality_scale, 1, 2, 1, 1);
		}

		// Bildqualität senden
		public void send_image_quality () {
			// Bildqualität senden
			viewer.Backend.TCPClient.get_default ().send_image_quality ((int)image_size_scale.get_value (), (int)image_quality_scale.get_value ());
		}
	}
}
