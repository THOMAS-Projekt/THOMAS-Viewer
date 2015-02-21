namespace viewer {
	// Konfigurationsverwaltung
	public class SettingsManager : Object {
		// Pfad
		static const string SETTINGS_PATH = "org.thomas.viewer";

		// Keys
		// TODO

		// Felder
		// TODO

		// Ereignisse
		// TODO

		// Gsettings-Client
		public Settings? settings = null;

		// Aktuelle Instanz
		public static SettingsManager? manager = null;

		// Instanzierung
		public SettingsManager () {
			// Mit dem Settings-Manager verbinden
			this.settings = new Settings (SETTINGS_PATH);
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
