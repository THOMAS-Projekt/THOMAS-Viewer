namespace viewer.Widgets {
	// Einstellungen
	public class Properties : Gtk.Grid {
		// Auto-Resize
		private Gtk.Label auto_resize_label;
		private Gtk.Switch auto_resize_switch;

		// Instanzierung
		public Properties () {
			// Abstände definieren
			this.margin = 12;
			this.row_spacing = 12;
			this.column_spacing = 12;

			// Auto-Resize-Label erstellen
			auto_resize_label = new Gtk.Label ("Bildgröße automatisch anpassen:");

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
		}
	}
}
