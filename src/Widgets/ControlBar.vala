namespace viewer.Widgets {
	// Steuerungsleiste
	public class ControlBar : Gtk.Revealer {
		// Aktionen
		private Gtk.ActionBar actions;

		// Zurück-Button
		private Gtk.Button back_button;

		// Gibt an ob sich die Maus über dem Objekt befindet
		private bool hovered = false;

		// Instanzierung
		public ControlBar () {
			// Zu überwachende Ereignisse festlegen
			this.events |= Gdk.EventMask.POINTER_MOTION_MASK;
			this.events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
			this.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

			// Animation setzen
			this.transition_type = Gtk.RevealerTransitionType.CROSSFADE;

			// Aktionsleiste erstellen
			actions = new Gtk.ActionBar ();

			// Größenverhalten der Aktionsleiste setzen
			actions.vexpand = false;

			// Aktionsleiste unten positionieren
			actions.valign = Gtk.Align.END;

			// Transparenz der Aktionsleiste setzen
			actions.opacity = 0.8;

			// Zurück-Button erstellen
			back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.BUTTON);

			// Zurück-Button zur Leiste hinzufügen
			actions.pack_start (back_button);

			// Aktionsleiste hinzufügen
			this.add (actions);

			// Die Maus wird auf das Objekt bewegt
			this.enter_notify_event.connect ((event) => {
				// Die Maus ist über dem Objekt
				hovered = true;

				// Fertig!
				return false;
			});

			// Die Maus verlässt das Objekt
			this.leave_notify_event.connect ((event) => {
				// Die Maus hat das Objekt verlassen
				hovered = false;

				// Fertig!
				return false;
			});

this.set_reveal_child(true);

			// Die hovered-Variable wird geändert
			notify["hovered"].connect (() => {
				if (hovered) {
					print ("drüber\n");
				} else {
					print ("nope\n");
				}
			});
		}
	}
}
