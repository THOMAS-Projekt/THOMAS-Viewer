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

public class Viewer.Backend.UDPRenderer : Object {
    private static const uint32 MAX_PACKAGE_SIZE = 64000;

    public signal void frame_received (Gdk.Pixbuf frame);

    private Socket udp_socket;
    private SocketSource? source = null;

    public UDPRenderer (uint16 port) {
        try {
            udp_socket = new Socket (SocketFamily.IPV4,
                                     SocketType.DATAGRAM,
                                     SocketProtocol.UDP);

            udp_socket.bind (new InetSocketAddress (new InetAddress.any (SocketFamily.IPV4), port), true);
        } catch (Error e) {
            warning ("Fehler beim Erstellen des UDP-Servers: %s", e.message);

            return;
        }

        Gdk.PixbufLoader frame_loader = new Gdk.PixbufLoader ();

        source = udp_socket.create_source (IOCondition.IN);
        source.set_callback ((socket, condition) => {
            try {
                uint8[] package = new uint8[MAX_PACKAGE_SIZE];

                uint package_length = (uint)socket.receive (package);

                frame_loader.write (package);

                /* Paket vollständig? */
                if (package_length < MAX_PACKAGE_SIZE) {
                    frame_loader.close ();

                    Gdk.Pixbuf? frame = frame_loader.get_pixbuf ();

                    if (frame != null) {
                        frame_received (frame);
                    }

                    frame_loader = new Gdk.PixbufLoader ();
                }
            } catch (Error e) {
                warning ("Fehler beim Empfangen eines Paketes: %s", e.message);

                frame_loader = new Gdk.PixbufLoader ();
            }

            return true;
        });

        source.attach (MainContext.@default ());
    }

    ~UDPRenderer () {
        if (source != null) {
            source.destroy ();
            udp_socket.close ();
        }
    }
}