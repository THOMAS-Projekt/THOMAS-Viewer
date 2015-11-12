/*
 * Copyright (c) 2011-2015 elementary Developers (https://launchpad.net/elementary)
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

[CCode (cheader_filename = "linux/joystick.h")]
namespace LinuxJoystick {
    /*
     * Version
     */

    [CCode (cname = "JS_VERSION")]
    public const int JS_VERSION;

    /*
     * Types and constants for reading from /dev/js
     */

    /**
     * Button pressed/released
     */
    [CCode (cname = "JS_EVENT_BUTTON")]
    public const int JS_EVENT_BUTTON;

    /**
     * Joystick moved
     */
    [CCode (cname = "JS_EVENT_AXIS")]
    public const int JS_EVENT_AXIS;

    /**
     * Initial state of device
     */
    [CCode (cname = "JS_EVENT_INIT")]
    public const int JS_EVENT_INIT;

    [CCode (cname = "struct js_event")]
    public struct Event {
        /**
         * Event timestamp in milliseconds
         */
        public uint32 time;

        /**
         * Value
         */
        public int16 value;

        /**
         * Event type
         */
        public uint8 type;

        /**
         * Axis/button number
         */
        public uint8 number;
    }

    /*
     * IOCTL commands for joystick driver
     */

    /**
     * Get driver version
     */
    [CCode (cname = "JSIOCGVERSION")]
    public const int JSIOCGVERSION;

    /**
     * Get number of axes
     */
    [CCode (cname = "JSIOCGAXES")]
    public const int JSIOCGAXES;

    /**
     * Get number of buttons
     */
    [CCode (cname = "JSIOCGBUTTONS")]
    public const int JSIOCGBUTTONS;

    /**
     * Get identifier string
     */
    [CCode (cname = "JSIOCGNAME")]
    public int JSIOCGNAME (uint len);

    /**
     * Set correction values
     */
    [CCode (cname = "JSIOCSCORR")]
    public const int JSIOCSCORR;

    /**
     * Get correction values
     */
    [CCode (cname = "JSIOCGCORR")]
    public const int JSIOCGCORR;

    /**
     * Set axis mapping
     */
    [CCode (cname = "JSIOCSAXMAP")]
    public const int JSIOCSAXMAP;

    /**
     * Get axis mapping
     */
    [CCode (cname = "JSIOCGAXMAP")]
    public const int JSIOCGAXMAP;

    /**
     * Set button mapping
     */
    [CCode (cname = "JSIOCSBTNMAP")]
    public const int JSIOCSBTNMAP;

    /**
     * Get button mapping
     */
    [CCode (cname = "JSIOCGBTNMAP")]
    public const int JSIOCGBTNMAP;

    /*
     * Types and constants for get/set correction
     */

    /**
     * Returns raw values
     */
    [CCode (cname = "JS_CORR_NONE")]
    public const int JS_CORR_NONE;

    /**
     * Broken line
     */
    [CCode (cname = "JS_CORR_BROKEN")]
    public const int JS_CORR_BROKEN;

    [CCode (cname = "struct js_corr")]
    public struct Corr {
        public int32 coef[8];
        public int16 prec;
        public uint16 type;
    }

    /*
     * v0.x compatibility definitions
     */

    [CCode (cname = "JS_RETURN")]
    public const int JS_RETURN;

    [CCode (cname = "JS_TRUE")]
    public const int JS_TRUE;

    [CCode (cname = "JS_FALSE")]
    public const int JS_FALSE;

    [CCode (cname = "JS_X_0")]
    public const int JS_X_0;

    [CCode (cname = "JS_Y_0")]
    public const int JS_Y_0;

    [CCode (cname = "JS_X_1")]
    public const int JS_X_1;

    [CCode (cname = "JS_Y_1")]
    public const int JS_Y_1;

    [CCode (cname = "JS_MAX")]
    public const int JS_MAX;

    [CCode (cname = "JS_DEF_TIMEOUT")]
    public const int JS_DEF_TIMEOUT;

    [CCode (cname = "JS_DEF_CORR")]
    public const int JS_DEF_CORR;

    [CCode (cname = "JS_DEF_TIMELIMIT")]
    public const int JS_DEF_TIMELIMIT;

    [CCode (cname = "JS_SET_CAL")]
    public const int JS_SET_CAL;

    [CCode (cname = "JS_GET_CAL")]
    public const int JS_GET_CAL;

    [CCode (cname = "JS_SET_TIMEOUT")]
    public const int JS_SET_TIMEOUT;

    [CCode (cname = "JS_GET_TIMEOUT")]
    public const int JS_GET_TIMEOUT;

    [CCode (cname = "JS_SET_TIMELIMIT")]
    public const int JS_SET_TIMELIMIT;

    [CCode (cname = "JS_GET_TIMELIMIT")]
    public const int JS_GET_TIMELIMIT;

    [CCode (cname = "JS_GET_ALL")]
    public const int JS_GET_ALL;

    [CCode (cname = "JS_SET_ALL")]
    public const int JS_SET_ALL;

    [CCode (cname = "struct JS_DATA_TYPE")]
    public struct DataType {
        public int32 buttons;
        public int32 x;
        public int32 y;
    }

    [CCode (cname = "struct JS_DATA_SAVE_TYPE_32")]
    public struct JS_DATA_SAVE_TYPE_32 {
        public int32 JS_TIMEOUT;
        public int32 BUSY;
        public int32 JS_EXPIRETIME;
        public int32 JS_TIMELIMIT;
        public DataType JS_SAVE;
        public DataType JS_CORR;
    }

    [CCode (cname = "struct JS_DATA_SAVE_TYPE_64")]
    public struct JS_DATA_SAVE_TYPE_64 {
        public int32 JS_TIMEOUT;
        public int32 BUSY;
        public int64 JS_EXPIRETIME;
        public int64 JS_TIMELIMIT;
        public DataType JS_SAVE;
        public DataType JS_CORR;
    }
}