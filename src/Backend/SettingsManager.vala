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

public class Viewer.Backend.SettingsManager : Granite.Services.Settings {
    public bool show_side_bar { get; set; default = true; }
    public string last_host { get; set; default = ""; }
    public string own_host { get; set; default = ""; }
    public bool auto_resize { get; set; default = true; }
    public int stream_quality { get; set; default = 70; }

    public SettingsManager () {
        base ("org.thomas.viewer");
    }
}