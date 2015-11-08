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

public class Viewer.Backend.BusManager : Object {
    private static const string SERVER_PATH = "/thomas/server";
    private static const string SERVER_NAME = "thomas.server";

    private static const int CALL_TIMEOUT = 10 * 1000;

    public enum Motor {
        LEFT = 2,
        RIGHT = 1,
        BOTH = 3
    }

    public signal void stream_registered (int streamer_id);

    public signal void connection_failure (string message);
    public signal void action_failure (string message);

    public SettingsManager settings_manager { private get; construct; }

    private DBusConnection? connection = null;

    public BusManager (SettingsManager settings_manager) {
        Object (settings_manager : settings_manager);
    }

    public void invalidate_connection () {
        connection = null;
    }

    public void set_motor_speed (Motor motor, int speed) {
        if (!validate_connection ()) {
            return;
        }

        Variant[] parameters = {
            new Variant.byte (motor),
            new Variant.int32 (speed)
        };

        connection.call.begin (null,
                               SERVER_PATH,
                               SERVER_NAME,
                               "SetMotorSpeed",
                               new Variant.tuple (parameters),
                               VariantType.TUPLE,
                               DBusCallFlags.NONE,
                               CALL_TIMEOUT,
                               null, (obj, res) => {
            try {
                if (!connection.call.end (res).get_child_value (0).get_boolean ()) {
                    action_failure ("Ein Zugriff auf die Motorsteuerung wird nicht unterstützt.");
                }
            } catch (Error e) {
                connection_failure (e.message);
            }
        });
    }

    public void accelerate_to_motor_speed (Motor motor, int speed) {
        if (!validate_connection ()) {
            return;
        }

        Variant[] parameters = {
            new Variant.byte (motor),
            new Variant.int32 (speed)
        };

        connection.call.begin (null,
                               SERVER_PATH,
                               SERVER_NAME,
                               "AccelerateToMotorSpeed",
                               new Variant.tuple (parameters),
                               VariantType.TUPLE,
                               DBusCallFlags.NONE,
                               CALL_TIMEOUT,
                               null, (obj, res) => {
            try {
                if (!connection.call.end (res).get_child_value (0).get_boolean ()) {
                    action_failure ("Ein Zugriff auf die Motorsteuerung wird nicht unterstützt.");
                }
            } catch (Error e) {
                connection_failure (e.message);
            }
        });
    }

    public void set_cam_position (uint8 camera, uint8 angle) {
        if (!validate_connection ()) {
            return;
        }

        Variant[] parameters = {
            new Variant.byte (camera),
            new Variant.byte (angle)
        };

        connection.call.begin (null,
                               SERVER_PATH,
                               SERVER_NAME,
                               "SetCamPosition",
                               new Variant.tuple (parameters),
                               VariantType.TUPLE,
                               DBusCallFlags.NONE,
                               CALL_TIMEOUT,
                               null, (obj, res) => {
            try {
                if (!connection.call.end (res).get_child_value (0).get_boolean ()) {
                    action_failure ("Ein Zugriff auf die Kamerasteuerung wird nicht unterstützt.");
                }
            } catch (Error e) {
                connection_failure (e.message);
            }
        });
    }

    public void change_cam_position (uint8 camera, uint8 degree) {
        if (!validate_connection ()) {
            return;
        }

        Variant[] parameters = {
            new Variant.byte (camera),
            new Variant.byte (degree)
        };

        connection.call.begin (null,
                               SERVER_PATH,
                               SERVER_NAME,
                               "ChangeCamPosition",
                               new Variant.tuple (parameters),
                               VariantType.TUPLE,
                               DBusCallFlags.NONE,
                               CALL_TIMEOUT,
                               null, (obj, res) => {
            try {
                if (!connection.call.end (res).get_child_value (0).get_boolean ()) {
                    action_failure ("Ein Zugriff auf die Kamerasteuerung wird nicht unterstützt.");
                }
            } catch (Error e) {
                connection_failure (e.message);
            }
        });
    }

    public void start_camera_stream (string viewer_host, uint16 viewer_port) {
        if (!validate_connection ()) {
            return;
        }

        Variant[] parameters = {
            new Variant.string (viewer_host),
            new Variant.uint16 (viewer_port)
        };

        connection.call.begin (null,
                               SERVER_PATH,
                               SERVER_NAME,
                               "StartCameraStream",
                               new Variant.tuple (parameters),
                               VariantType.TUPLE,
                               DBusCallFlags.NONE,
                               CALL_TIMEOUT,
                               null, (obj, res) => {
            try {
                int streamer_id = connection.call.end (res).get_child_value (0).get_int32 ();

                if (streamer_id < 0) {
                    action_failure ("Ein Zugriff auf die Kamera wird nicht unterstützt.");
                } else {
                    stream_registered (streamer_id);
                }
            } catch (Error e) {
                connection_failure (e.message);
            }
        });
    }

    private bool validate_connection () {
        if (connection != null && !connection.closed) {
            return true;
        }

        debug ("Stelle neue DBus-Verbindung her...");

        try {
            connection = new DBusConnection.for_address_sync ("tcp:host=%s,port=4242".printf (settings_manager.last_host),
                                                              DBusConnectionFlags.AUTHENTICATION_CLIENT);
        } catch (Error e) {
            warning ("Herstellen der DBus-Verbindung fehlgeschlagen: %s", e.message);
            connection_failure (e.message);

            return false;
        }

        debug ("Neue DBus-Verbindung aufgebaut.");

        /* Nur um nochmals sicherzugehen */
        return (connection != null && !connection.closed);
    }
}