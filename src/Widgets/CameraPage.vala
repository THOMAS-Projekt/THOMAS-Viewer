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

public class Viewer.Widgets.CameraPage : Gtk.Overlay {
    public Backend.SettingsManager settings_manager { private get; construct; }
    public Backend.UDPRenderer renderer { private get; construct; }

    public signal void stream_quality_changed (int stream_quality);

    private Gtk.Image frame_view;

    private Gtk.Revealer action_revealer;
    private Gtk.ActionBar action_bar;

    private Gtk.Label auto_resize_label;
    private Gtk.Switch auto_resize_switch;

    private Gtk.Label quality_label;
    private Gtk.Adjustment quality_adjustment;
    private Gtk.Scale quality_scale;

    public CameraPage (Backend.SettingsManager settings_manager, Backend.UDPRenderer renderer) {
        Object (settings_manager: settings_manager, renderer: renderer);

        build_ui ();
        create_bindings ();
        connect_signals ();
    }

    private void build_ui () {
        this.events |= Gdk.EventMask.POINTER_MOTION_MASK |
                       Gdk.EventMask.LEAVE_NOTIFY_MASK |
                       Gdk.EventMask.ENTER_NOTIFY_MASK;

        frame_view = new Gtk.Image ();

        action_revealer = new Gtk.Revealer ();
        action_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        action_revealer.transition_duration = 150;

        action_bar = new Gtk.ActionBar ();
        action_bar.valign = Gtk.Align.END;
        action_bar.opacity = 0.85;

        auto_resize_label = new Gtk.Label ("Skalieren:");
        auto_resize_label.margin_start = 6;

        auto_resize_switch = new Gtk.Switch ();
        auto_resize_switch.margin = 6;

        quality_label = new Gtk.Label ("Qualität:");

        quality_adjustment = new Gtk.Adjustment (settings_manager.stream_quality, 0, 100, 1, 10, 1);

        quality_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, quality_adjustment);
        quality_scale.draw_value = false;
        quality_scale.margin = 6;
        quality_scale.set_size_request (150, -1);

        action_bar.pack_start (auto_resize_label);
        action_bar.pack_start (auto_resize_switch);

        action_bar.pack_end (quality_scale);
        action_bar.pack_end (quality_label);

        action_revealer.add (action_bar);

        /*
         * Das Kamerabild muss ebenfalls als Overlay dargestellt werden,
         * damit sich dessen Größe nicht auf die Fenstergröße auswirkt.
         */
        this.add_overlay (frame_view);
        this.add_overlay (action_revealer);
    }

    private void create_bindings () {
        settings_manager.bind_property ("stream-quality",
                                        quality_adjustment,
                                        "value",
                                        BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

        settings_manager.bind_property ("auto-resize",
                                        auto_resize_switch,
                                        "state",
                                        BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
    }

    private void connect_signals () {
        this.enter_notify_event.connect (() => {
            action_revealer.set_reveal_child (true);

            return Gdk.EVENT_PROPAGATE;
        });

        this.leave_notify_event.connect (() => {
            action_revealer.set_reveal_child (false);

            return Gdk.EVENT_PROPAGATE;
        });

        renderer.frame_received.connect (display_frame);

        quality_adjustment.value_changed.connect (() => {
            stream_quality_changed ((int)quality_adjustment.value);
        });
    }

    /*
     * Wird durch das Signal aus einem seperaten Thread heraus aufgerufen,
     * daher müssen GUI-Zugriffe in die MainLoop zurückverschoben werden.
     */
    private void display_frame (Gdk.Pixbuf frame) {
        if (settings_manager.auto_resize) {
            int new_width, new_height;

            resize_dimensions (frame.width,
                               frame.height,
                               this.get_allocated_width (),
                               this.get_allocated_height (),
                               out new_width,
                               out new_height);

            Gdk.Pixbuf scaled_frame = frame.scale_simple (new_width, new_height, Gdk.InterpType.NEAREST);

            Idle.add (() => {
                frame_view.set_from_pixbuf (scaled_frame);

                return false;
            });
        } else {
            Idle.add (() => {
                frame_view.set_from_pixbuf (frame);

                return false;
            });
        }
    }

    private void resize_dimensions (int frame_width,
                                    int frame_height,
                                    int target_width,
                                    int target_height,
                                    out int new_width,
                                    out int new_height) {
        new_width = target_width;
        new_height = (int)(((float)target_width / frame_width) * frame_height);

        if (new_height > target_height) {
            new_width = (int)(((float)target_height / frame_height) * frame_width);
            new_height = target_height;
        }
    }
}