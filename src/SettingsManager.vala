namespace viewer {
	// Konfigurationsverwaltung
	public class SettingsManager : Object {
		// Pfad
		static const string SETTINGS_PATH = "org.thomas.viewer";

		// Keys
		static const string AUTO_RESIZE_KEY = "auto-resize";
		static const string LAST_HOST_KEY = "last-host";

		// Felder
		public bool auto_resize { get; set; default = true; }
		public string last_host { get; set; default = ""; }

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
