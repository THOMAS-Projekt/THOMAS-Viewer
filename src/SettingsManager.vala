namespace viewer {
	// Konfigurationsverwaltung
	public class SettingsManager : Object {
		// Pfad
		static const string SETTINGS_PATH = "org.thomas.viewer";

		// Keys
		static const string AUTO_RESIZE_KEY = "auto-resize";
		static const string LAST_HOST_KEY = "last-host";
		static const string IMAGE_SIZE_KEY = "image-size";
		static const string IMAGE_QUALITY_KEY = "image-quality";

		// Felder
		public bool auto_resize { get; set; default = true; }
		public string last_host { get; set; default = ""; }
		public int image_size { get; set; default = 50; }
		public int image_quality { get; set; default = 30; }

		// Ereignisse
		public signal void last_host_changed ();

		// Gsettings-Client
		public Settings? settings = null;

		// Aktuelle Instanz
		public static SettingsManager? manager = null;

		// Instanzierung
		public SettingsManager () {
			// Mit dem Settings-Manager verbinden
			this.settings = new Settings (SETTINGS_PATH);

			// Keys verknüpfen
			this.settings.bind (AUTO_RESIZE_KEY, this, "auto-resize", SettingsBindFlags.DEFAULT);
			this.settings.bind (LAST_HOST_KEY, this, "last-host", SettingsBindFlags.DEFAULT);
			this.settings.bind (IMAGE_SIZE_KEY, this, "image-size", SettingsBindFlags.DEFAULT);
			this.settings.bind (IMAGE_QUALITY_KEY, this, "image-quality", SettingsBindFlags.DEFAULT);

			// Ereignisse verknüpfen
			this.settings.changed[LAST_HOST_KEY].connect (() => { this.last_host_changed (); });
		}

		// Instanz abrufen
		public static SettingsManager get_default () {
			// Bereits instanziert?
			if (manager == null) {
				// Nein => Erstellen
				manager = new SettingsManager ();
			}

			// Instanz zurückgeben
			return manager;
		}
	}
}
