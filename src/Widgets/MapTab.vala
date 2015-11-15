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
        int angle_before = 0;
        double last_avg_sum = 0;

        int height = drawing_area.get_allocated_height ();
        int width = drawing_area.get_allocated_width ();

        double thomas_x = width * 0.5;
        double thomas_y = height * 0.8;
        debug (thomas_x.to_string () + " - " + thomas_y.to_string ());

        /* THOMAS zeichnen */
        draw_circle (context, thomas_x, thomas_y, 5, { 0, 0, 0, 255 });

        /* Messwerte zeichnen */
        distances.@foreach ((entry) => {
            int angle = entry.key - 15;
            Gee.ArrayList<uint16> distances = entry.@value;

            double avg_sum = calculate_avg_sum (0, 10, distances);

            double avg_difference = calculate_avg_difference (0, 10, avg_sum, distances);

            if (avg_difference < 1.5) {
                double distance_x_position = thomas_x - (Math.cos (to_radians (angle)) * avg_sum);
                double distance_y_position = thomas_y - (Math.sin (to_radians (angle)) * avg_sum);

                double distance_x_before = thomas_x - (Math.cos (to_radians (angle_before)) * avg_sum);
                double distance_y_before = thomas_y - (Math.sin (to_radians (angle_before)) * avg_sum);

                double distance_beetween_points = calculate_distance (distance_x_position, distance_x_before, distance_y_position, distance_y_before);

                if (distance_beetween_points > 40) {

                    double real_distance_x = thomas_x - (Math.cos (to_radians (angle_before)) * last_avg_sum);
                    double real_distance_y = thomas_y - (Math.sin (to_radians (angle_before)) * last_avg_sum);

                    context.set_line_width (3);
                    context.set_source_rgba (1, 0.2, 0.2, 0.6);
                    context.move_to (distance_x_position, distance_y_position);
                    context.line_to (real_distance_x, real_distance_y);
                    context.stroke();

                    debug("FROM %f, %f TO: %f,%f", distance_x_position, distance_y_position, distance_x_before, distance_y_before);
                }

                draw_circle (context,
                             distance_x_position,
                             distance_y_position,
                             1,
                             { 0, 255, 0, 255 });

                angle_before = angle;
                last_avg_sum = avg_sum;
            }

            return true;
        });

        return Gdk.EVENT_PROPAGATE;
    }

    private void draw_circle (Cairo.Context context, double pos_x, double pos_y, int radius, Gdk.RGBA color) {
        context.arc (pos_x, pos_y, radius, 0, 2 * Math.PI);

        Gdk.cairo_set_source_rgba (context, color);
        context.fill ();
    }

    private double to_radians (int degree) {
        return ((Math.PI / 180) * degree);
    }

    private double calculate_avg_sum (int start, int end, Gee.ArrayList<uint16> distances) {
        double sum = 0;

        for (int i = 0; i < 10; i++) {
            sum += distances.@get (i);
        }

        return sum / (end - start);
    }

    private double calculate_avg_difference (int start, int end, double avg_sum, Gee.ArrayList<uint16> distances) {
        double avg_calc = 0;

        for (int i = 0; i < 10; i++) {
            avg_calc += Math.fabs ((distances.@get (i) - avg_sum));
        }

        return (avg_calc / avg_sum);
    }

    private double calculate_distance (double x1, double x2, double y1, double y2) {
        /* Distanz zwischen zwei Punkten berechnen und Wurzel ziehen ignorieren, um Leistung zu sparen */
        return Math.sqrt ((Math.pow (x2 - x1, 2) + (Math.pow (y2 - y1, 2))));
    }
}