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

public class Viewer.Backend.JoystickManager : Object {
    private static const string INPUT_DEVICE_DIRECTORY = "/dev/input/";

    private static const int MAX_MOTOR_SPEED = 255;
    private static const double JOYSTICK_SPEED_CONVERSION_FACTOR = (double)MAX_MOTOR_SPEED / Joystick.MAX_AXIS_VALUE;

    public BusManager bus_manager{ private get; construct; }

    private Gee.HashMap<string, Joystick> joysticks;
    private Joystick? selected_joystick = null;

    private int axis_north_south_value = 0;
    private int axis_west_east_value = 0;
    private int axis_rotation_value = 0;

    public JoystickManager (BusManager bus_manager) {
        Object (bus_manager : bus_manager);

        joysticks = new Gee.HashMap<string, Joystick> ();

        load_joysticks ();
    }

    ~JoystickManager () {
    }

    public Gee.Collection<Joystick> get_joysticks () {
        return joysticks.values;
    }

    public void select_joystick (string? input_device) {
        if (selected_joystick != null) {
            selected_joystick.button_changed.disconnect (process_button_change);
            selected_joystick.axis_changed.disconnect (process_axis_change);
        }

        if (input_device == null || !joysticks.has_key (input_device)) {
            selected_joystick = null;

            debug ("Joysticksteuerung deaktiviert.");
        } else {
            selected_joystick = joysticks.@get (input_device);
            selected_joystick.button_changed.connect (process_button_change);
            selected_joystick.axis_changed.connect (process_axis_change);

            debug ("Joystick \"%s\" gewählt.", selected_joystick.device_name);
        }
    }

    private void load_joysticks () {
        debug ("Suche nach Joysticks...");

        try{
            File file = File.new_for_path (INPUT_DEVICE_DIRECTORY);
            FileEnumerator enumerator = file.enumerate_children (FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
            FileInfo? file_info = null;

            while ((file_info = enumerator.next_file ()) != null) {
                string input_device_name = file_info.get_name ();

                if (!input_device_name.has_prefix ("js")) {
                    continue;
                }

                register_joystick (file_info.get_name ());
            }
        } catch (Error e) {
            warning ("Joystick-Suche fehlgeschlagen: %s", e.message);
        }
    }

    private void register_joystick (string input_device_name) {
        string input_device = INPUT_DEVICE_DIRECTORY + input_device_name;

        Joystick joystick = new Joystick (input_device);
        joystick.setup ();

        joysticks.@set (input_device, joystick);

        debug ("Joystick \"%s\" registriert.", joystick.device_name);

        if (selected_joystick == null) {
            select_joystick (input_device);
        }
    }

    private void process_button_change (uint8 button_hash, bool button_state) {
        debug ("%d -> %s", button_hash, button_state.to_string ());
    }

    private void process_axis_change (uint8 axis_hash, int axis_value) {
        switch (axis_hash) {
            case Joystick.Axis.SIDEWINDER_AXIS_NORTH_SOUTH :
            case Joystick.Axis.XBOX_AXIS_TOP_NORTH_SOUTH :
                axis_north_south_value = axis_value;

                break;

            case Joystick.Axis.SIDEWINDER_AXIS_WEST_EAST:
            case Joystick.Axis.XBOX_AXIS_TOP_WEST_EAST:
                axis_west_east_value = axis_value;

                break;

            case Joystick.Axis.SIDEWINDER_AXIS_ROTATION:
                axis_rotation_value = axis_value;

                break;

            default:

                return;
        }

        /* Die neuen Geschwindigkeitswerte */
        int speed_left = 0, speed_right = 0;

        /* Prüfen, ob eine nennenswerte Achsenbewegung eintrat, ansonsten (wenn vorhanden) mit Hilfe der R-Achse drehen */
        if (axis_north_south_value.abs () >= Joystick.AXIS_TOLERANCE || axis_west_east_value.abs () >= Joystick.AXIS_TOLERANCE) {
            /* Summe der Achsauslenkungen berechnen */
            int axis_sum = axis_north_south_value.abs () + axis_west_east_value.abs ();

            /* Prüfen, ob die Joystickauslenkung innerhalb des steuerungsbereiches liegt */
            if (axis_sum <= Joystick.MAX_AXIS_VALUE) {
                /* Geschwindigkeiten berechnen */
                speed_left = -(int)(JOYSTICK_SPEED_CONVERSION_FACTOR * (-axis_west_east_value + axis_north_south_value));
                speed_right = -(int)(JOYSTICK_SPEED_CONVERSION_FACTOR * (axis_west_east_value + axis_north_south_value));
            } else {
                /* Auslenkungswerte reduzieren und Geschwindigkeiten berechnen */
                speed_left = -(int)(((double)MAX_MOTOR_SPEED / axis_sum) * (-axis_west_east_value + axis_north_south_value));
                speed_right = -(int)(((double)MAX_MOTOR_SPEED / axis_sum) * (axis_west_east_value + axis_north_south_value));
            }
        } else {
            /* Geschwindigkeit für Drehung um eigene Achse berechnen */
            speed_left = (int)(JOYSTICK_SPEED_CONVERSION_FACTOR * axis_rotation_value);
            speed_right = -(int)(JOYSTICK_SPEED_CONVERSION_FACTOR * axis_rotation_value);
        }

	debug("%i %i -> %i : %i", axis_north_south_value, axis_west_east_value, speed_left, speed_right);	
        /* Geschwindigkeiten senden */
        bus_manager.accelerate_to_motor_speed (BusManager.Motor.LEFT, speed_left);
        bus_manager.accelerate_to_motor_speed (BusManager.Motor.RIGHT, speed_right);
    }
}
