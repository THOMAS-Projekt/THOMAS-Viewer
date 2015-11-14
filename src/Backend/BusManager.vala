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
    public signal void action_success ();

    public signal void cpu_load_changed (double cpu_load);
    public signal void memory_usage_changed (double memory_usage);
    public signal void net_load_changed (uint64 bytes_in, uint64 bytes_out);
    public signal void free_drive_space_changed (int megabytes);

    public SettingsManager settings_manager { private get; construct; }

    private DBusConnection? connection = null;

    public BusManager (SettingsManager settings_manager) {
        Object (settings_manager : settings_manager);
    }

    ~BusManager () {
        if (connection != null && !connection.closed) {
            connection.close.begin ();
            debug ("DBus-Verbindung geschlossen.");
        }
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
                } else {
                    action_success ();
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
                } else {
                    action_success ();
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
                } else {
                    action_success ();
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
                } else {
                    action_success ();
                }
            } catch (Error e) {
                connection_failure (e.message);
            }
        });
    }

    public async int start_camera_stream (string viewer_host, uint16 viewer_port) {
        if (!validate_connection ()) {
            return -1;
        }

        Variant[] parameters = {
            new Variant.string (viewer_host),
            new Variant.uint16 (viewer_port)
        };

        int streamer_id = -1;

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
                streamer_id = connection.call.end (res).get_child_value (0).get_int32 ();

                if (streamer_id < 0) {
                    action_failure ("Ein Zugriff auf die Kamera wird nicht unterstützt.");
                } else {
                    stream_registered (streamer_id);
                    action_success ();
                }
            } catch (Error e) {
                connection_failure (e.message);
            }

            start_camera_stream.callback ();
        });
        yield;

        return streamer_id;
    }

    public void stop_camera_stream (int streamer_id) {
        if (!validate_connection ()) {
            return;
        }

        Variant[] parameters = {
            new Variant.int32 (streamer_id)
        };

        connection.call.begin (null,
                               SERVER_PATH,
                               SERVER_NAME,
                               "StopCameraStream",
                               new Variant.tuple (parameters),
                               VariantType.TUPLE,
                               DBusCallFlags.NONE,
                               CALL_TIMEOUT,
                               null, (obj, res) => {
            try {
                if (!connection.call.end (res).get_child_value (0).get_boolean ()) {
                    action_failure ("Ein Zugriff auf die Kamerasteuerung wird nicht unterstützt.");
                } else {
                    action_success ();
                }
            } catch (Error e) {
                connection_failure (e.message);
            }
        });
    }

    public void set_camera_stream_options (int streamer_id, int image_quality, int image_density) {
        if (!validate_connection ()) {
            return;
        }

        Variant[] parameters = {
            new Variant.int32 (streamer_id),
            new Variant.int32 (image_quality),
            new Variant.int32 (image_density)
        };

        connection.call.begin (null,
                               SERVER_PATH,
                               SERVER_NAME,
                               "SetCameraStreamOptions",
                               new Variant.tuple (parameters),
                               VariantType.TUPLE,
                               DBusCallFlags.NONE,
                               CALL_TIMEOUT,
                               null, (obj, res) => {
            try {
                if (!connection.call.end (res).get_child_value (0).get_boolean ()) {
                    action_failure ("Ein Zugriff auf die Kamerasteuerung wird nicht unterstützt.");
                } else {
                    action_success ();
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

            connection.signal_subscribe (null, SERVER_NAME,
                                         "CpuLoadChanged",
                                         SERVER_PATH,
                                         null,
                                         DBusSignalFlags.NONE,
                                         on_cpu_load_changed);

            connection.signal_subscribe (null, SERVER_NAME,
                                         "MemoryUsageChanged",
                                         SERVER_PATH,
                                         null,
                                         DBusSignalFlags.NONE,
                                         on_memory_usage_changed);

            connection.signal_subscribe (null, SERVER_NAME,
                                         "NetLoadChanged",
                                         SERVER_PATH,
                                         null,
                                         DBusSignalFlags.NONE,
                                         on_net_load_changed);

            connection.signal_subscribe (null, SERVER_NAME,
                                         "FreeDriveSpaceChanged",
                                         SERVER_PATH,
                                         null,
                                         DBusSignalFlags.NONE,
                                         on_free_drive_space_changed);
        } catch (Error e) {
            warning ("Herstellen der DBus-Verbindung fehlgeschlagen: %s", e.message);
            connection_failure (e.message);

            return false;
        }

        debug ("Neue DBus-Verbindung aufgebaut.");

        /* Nur um nochmals sicherzugehen */
        return (connection != null && !connection.closed);
    }

    private void on_cpu_load_changed (DBusConnection connection,
                                      string ? sender_name,
                                      string object_path,
                                      string interface_name,
                                      string signal_name,
                                      Variant paramerers) {
        cpu_load_changed (paramerers.get_child_value (0).get_double ());
    }

    private void on_memory_usage_changed (DBusConnection connection,
                                          string ? sender_name,
                                          string object_path,
                                          string interface_name,
                                          string signal_name,
                                          Variant paramerers) {
        memory_usage_changed (paramerers.get_child_value (0).get_double ());
    }

    private void on_net_load_changed (DBusConnection connection,
                                      string ? sender_name,
                                      string object_path,
                                      string interface_name,
                                      string signal_name,
                                      Variant paramerers) {
        net_load_changed (paramerers.get_child_value (0).get_uint64 (),
                          paramerers.get_child_value (1).get_uint64 ());
    }

    private void on_free_drive_space_changed (DBusConnection connection,
                                              string ? sender_name,
                                              string object_path,
                                              string interface_name,
                                              string signal_name,
                                              Variant paramerers) {
        free_drive_space_changed (paramerers.get_child_value (0).get_int32 ());
    }
}