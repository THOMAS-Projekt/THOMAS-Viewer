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
    public Backend.UDPRenderer renderer { private get; construct; }

    private Gtk.Image frame_view;

    public CameraPage (Backend.UDPRenderer renderer) {
        Object (renderer: renderer);

        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        frame_view = new Gtk.Image ();

        this.add (frame_view);
    }

    private void connect_signals () {
        renderer.frame_received.connect ((frame) => {
            frame_view.set_from_pixbuf (frame);
        });
    }
}