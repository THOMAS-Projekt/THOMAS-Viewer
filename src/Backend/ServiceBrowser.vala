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

public class Viewer.Backend.ServiceBrowser : Object {
    private static const string SERVICE_TYPE = "_thomas._tcp";

    public signal void thomas_discovered (string hostname, uint port);

    private Avahi.Client client;
    private Avahi.ServiceBrowser browser;

    public ServiceBrowser () {
        client = new Avahi.Client ();
        browser = new Avahi.ServiceBrowser (SERVICE_TYPE);

        connect_signals ();
        start_client ();
    }

    private void connect_signals () {
        client.state_changed.connect ((state) => {
            switch (state) {
                case Avahi.ClientState.S_RUNNING :
                    try {
                        browser.attach (client);
                    } catch (Error e) {
                        warning ("Konfigurieren des Avahi-Eintrages fehlgeschlagen: %s", e.message);
                    }

                    break;
            }
        });

        browser.new_service.connect ((@interface, protocol, name, type, domain, flags) => {
            debug ("Server \"%s\" entdeckt.", name);

            Avahi.ServiceResolver resolver = new Avahi.ServiceResolver (interface, protocol, name, type, domain, Avahi.Protocol.UNSPEC);

            resolver.failure.connect ((error) => {
                warning ("Auflösen des Dienstes fehlgeschlagen: %s", error.message);
            });

            resolver.found.connect ((@interface, protocol, name, type, domain, hostname, address, port, txt, flags) => {
                thomas_discovered (hostname, port);
            });

            try {
                resolver.attach (client);
            } catch (Error e) {
                warning ("Konfigurieren des Avahi-Browsers fehlgeschlagen: %s", e.message);
            }

            /* FIXME: Dieses Objekt müsste eigentlich auch wieder zerstört werden, dies führt allerdings zu Problemen. */
            resolver.ref ();
        });

        browser.failure.connect ((error) => {
            warning ("Suche nach Diensten fehlgeschlagen: %s", error.message);
        });
    }

    private void start_client () {
        try {
            client.start ();
        } catch (Error e) {
            warning ("Verbindung zu Avahi fehlgeschlagen: %s", e.message);
        }
    }
}