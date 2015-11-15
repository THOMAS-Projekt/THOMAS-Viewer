/*
 * Copyright (c) 2011-2015 THOMAS-Projekt (https://thomas-projekt.de)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Viewer.Backend.Joystick : Object {
    public static const int MAX_AXIS_VALUE = short.MAX;
    public static const int AXIS_TOLERANCE = MAX_AXIS_VALUE / 10;

    /* Alle Button-IDs der Joysticks */
    public enum Button {
        SIDEWINDER_BUTTON_FIRE = 0,
        SIDEWINDER_BUTTON_TOP_LEFT = 1,
        SIDEWINDER_BUTTON_TOP_RIGHT_TOP = 2,
        SIDEWINDER_BUTTON_TOP_RIGHT_BOTTOM = 3,
        SIDEWINDER_BUTTON_A = 4,
        SIDEWINDER_BUTTON_B = 5,
        SIDEWINDER_BUTTON_C = 6,
        SIDEWINDER_BUTTON_D = 7,
        SIDEWINDER_BUTTON_FRONT_UP = 8,

        XBOX_BUTTON_A = 32,
        XBOX_BUTTON_B = 33,
        XBOX_BUTTON_X = 34,
        XBOX_BUTTON_Y = 35,
        XBOX_BUTTON_LB = 36,
        XBOX_BUTTON_LR = 37,
        XBOX_BUTTON_LT = 38,
        XBOX_BUTTON_RT = 39,
        XBOX_BUTTON_BACK = 40,
        XBOX_BUTTON_START = 41,
        XBOX_BUTTON_LOGO = 42,
        XBOX_BUTTON_AXIS_TOP = 43,
        XBOX_BUTTON_AXIS_BOTTOM = 44,
        XBOX_BUTTON_WEST = 45,
        XBOX_BUTTON_EAST = 46,
        XBOX_BUTTON_NORTH = 47,
        XBOX_BUTTON_SOUTH = 48
    }

    /* Alle Achsen-IDs der Joysticks */
    public enum Axis {
        SIDEWINDER_AXIS_WEST_EAST = 0,
        SIDEWINDER_AXIS_NORTH_SOUTH = 1,
        SIDEWINDER_AXIS_ROTATION = 2,
        SIDEWINDER_AXIS_SCROLL_WHEEL = 3,
        SIDEWINDER_AXIS_TOP_WEAST_EAST = 4,
        SIDEWINDER_AXIS_TOP_NORTH_SOUTH = 5,

        XBOX_AXIS_TOP_WEST_EAST = 32,
        XBOX_AXIS_TOP_NORTH_SOUTH = 33,
        XBOX_AXIS_BOTTOM_WEST_EAST = 34,
        XBOX_AXIS_BOTTOM_NORTH_SOUTH = 35,
    }

    /* Arrayposition der Joystickinformatinen */
    public enum JoystickInfoField {
        BUTTON_COUNT,
        AXIS_COUNT
    }

    /* Betätigungsereignisse */
    public signal void button_changed (uint8 button_hash, bool button_state);
    public signal void axis_changed (uint8 axis_hash, int axis_value);

    /* Gerätestream des Joysticks */
    public string input_device { get; construct; }

    /* Der Name des Joysticks */
    public string device_name { get; private set; }

    /* Die Joystick-ID */
    public uint8 device_id { get; private set; }

    /* Die Informations-Daten zum Joystick */
    public uint8[] device_info { get; private set; }

    /* Kommunikationshandle */
    private int handle = -1;

    public Joystick (string input_device) {
        Object (input_device: input_device);

        attach ();
    }

    ~Joystick () {
        detach ();
    }

    private void attach () {
        /* Joystickport öffnen */
        handle = Posix.open (input_device, Posix.O_RDONLY);

        /* Fehler ausgeben beim Verbindungsfehler */
        if (handle == -1) {
            warning ("Öffnen von %s fehlgeschlagen.", input_device);
        }

        /* Neues leeres Joystickinfo-Array erstellen */
        device_info = new uint8[2];

        /* Joystickdaten auslesen */
        Posix.ioctl (handle, LinuxJoystick.JSIOCGAXES, out device_info[JoystickInfoField.AXIS_COUNT]);
        Posix.ioctl (handle, LinuxJoystick.JSIOCGBUTTONS, out device_info[JoystickInfoField.BUTTON_COUNT]);

        /* Gerätenamen abrufen */
        char name[128];
        device_name = (Posix.ioctl (handle, LinuxJoystick.JSIOCGNAME (name.length), name) < 0) ? "Unkown Name" : (string)name;

        /* Joystick-ID ermitteln */
        device_id = get_joystick_id (device_name);
    }

    private void detach () {
        if (handle == -1) {
            return;
        }

        /* Schnittstelle schließen */
        Posix.close (handle);

        debug ("Schnittstelle %s geschlossen.", input_device);
    }

    /* Abrufen der Joystick-Daten starten */
    public void setup () {
        new Thread<int> (null, () => {
            /* Zähler für die Initialisierungs-Bytes */
            int init_bytes_read = 0;

            while (true) {
                /* Neues JoystickEvent erstellen */
                var e = LinuxJoystick.Event ();

                /* Daten lesen */
                var read_size = Posix.read (handle, &e, sizeof (LinuxJoystick.Event));

                /* Prüfen, ob die Daten vollständig empfangen wurden */
                if (read_size != sizeof (LinuxJoystick.Event)) {
                    warning ("Fehler beim Lesen von Joystickdaten.");
                }

                /* Prüfen, ob alle Initialisierungs-Bytes schon empfangen wurden */
                if (init_bytes_read < device_info[JoystickInfoField.BUTTON_COUNT] + device_info[JoystickInfoField.AXIS_COUNT]) {
                    init_bytes_read++;

                    continue;
                }

                /* Daten analysieren und entsprechendes Ereignis auslösen */
                switch (e.type & (~LinuxJoystick.JS_EVENT_INIT)) {
                    case (uint8)LinuxJoystick.JS_EVENT_BUTTON:
                        button_changed ((device_id << 5) | e.number, (bool)e.value);

                        break;

                    case (uint8)LinuxJoystick.JS_EVENT_AXIS:
                        axis_changed ((device_id << 5) | e.number, e.value);

                        break;
                }
            }
        });
    }

    /* Die JoystickID anhand des Namens ermitteln */
    private uint8 get_joystick_id (string device_name) {
        switch (device_name) {
            case "Microsoft Microsoft SideWinder Precision Pro (USB)":

                return 0;

            case "Microsoft X-Box 360 pad":
            case "Xbox 360 Wireless Receiver":

                return 1;

            default:
                warning ("Der angeschlossene Joystick ist nicht bekannt.");

                return 0;
        }
    }
}
