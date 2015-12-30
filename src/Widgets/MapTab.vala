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

public class Viewer.Widgets.MapTab : Granite.Widgets.Tab {
    private static const int SENSOR_ANGLE_OFFSET = -15;
    private static const int CONNECT_DISTANCES_MIN_RADIUS = 50;
    private static const int CONNECT_DISTANCES_MAX_RADIUS = 200;

    public int map_id { get; construct set; }
    public string map_name { get; construct set; }

    private Gtk.DrawingArea drawing_area;

    private Gee.TreeMap<uint8, Gee.ArrayList<uint16> > distances;

    public MapTab (int map_id, string map_name) {
        base (map_name, null, null);

        this.map_id = map_id;
        this.map_name = map_name;

        distances = new Gee.TreeMap<uint8, Gee.ArrayList<uint16> > ();

        build_ui ();
        connect_signals ();
    }

    public void add_distances (uint8 angle, uint16[] step_distances) {
        Gee.ArrayList<uint16> distance_list = new Gee.ArrayList<uint16> ();

        foreach (uint16 distance in step_distances) {
            distance_list.add (distance);
        }

        distances.@set (angle, distance_list);

        drawing_area.queue_draw ();
    }

    private void build_ui () {
        drawing_area = new Gtk.DrawingArea ();

        this.page = drawing_area;
    }

    private void connect_signals () {
        drawing_area.draw.connect (on_draw);
    }

    private bool on_draw (Cairo.Context context) {
        int height = drawing_area.get_allocated_height ();
        int width = drawing_area.get_allocated_width ();

        double thomas_x = width * 0.5;
        double thomas_y = height * 0.8;

        double last_near_distance_x = 0;
        double last_near_distance_y = 0;

        /* THOMAS zeichnen */
        draw_circle (context, thomas_x, thomas_y, 5, { 0, 0, 0, 255 });

        /* Messwerte zeichnen */
        distances.@foreach ((entry) => {
            int angle = entry.key + SENSOR_ANGLE_OFFSET;
            Gee.ArrayList<uint16> distances = entry.@value;

            double avg_sum = calculate_avg_sum (0, 10, distances);

            double distance_x = thomas_x - (Math.cos (to_radians (angle)) * avg_sum);
            double distance_y = thomas_y - (Math.sin (to_radians (angle)) * avg_sum);

            draw_circle (context,
                         distance_x,
                         distance_y,
                         2,
                         { 255, 255, 255, 255 });

            if (avg_sum >= CONNECT_DISTANCES_MIN_RADIUS && avg_sum <= CONNECT_DISTANCES_MAX_RADIUS) {
                if (last_near_distance_x > 0 && last_near_distance_y > 0) {
                    draw_line (context,
                               last_near_distance_x,
                               last_near_distance_y,
                               distance_x,
                               distance_y,
                               1,
                               { 255, 255, 255, 255 });
                }

                last_near_distance_x = distance_x;
                last_near_distance_y = distance_y;
            }

            return true;
        });

        return Gdk.EVENT_PROPAGATE;
    }

    private void draw_circle (Cairo.Context context, double pos_x, double pos_y, int radius, Gdk.RGBA color) {
        Gdk.cairo_set_source_rgba (context, color);

        context.arc (pos_x, pos_y, radius, 0, 2 * Math.PI);
        context.fill ();
    }

    private void draw_line (Cairo.Context context, double pos1_x, double pos1_y, double pos2_x, double pos2_y, int width, Gdk.RGBA color) {
        Gdk.cairo_set_source_rgba (context, color);

        context.set_line_width (width);
        context.move_to (pos1_x, pos1_y);
        context.line_to (pos2_x, pos2_y);
        context.stroke ();
    }

    private double to_radians (int degree) {
        return ((Math.PI / 180) * degree);
    }

    private double calculate_avg_sum (int start, int end, Gee.ArrayList<uint16> distances) {
        double sum = 0;

        for (int i = start; i < end; i++) {
            sum += distances.@get (i);
        }

        return sum / (end - start);
    }
}