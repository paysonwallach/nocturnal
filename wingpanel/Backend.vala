public class Nocturnal.Backend : GLib.Object {
    private enum Schedule {
        DISABLED,
        AUTOMATIC,
        MANUAL;
    }

    // private enum ColorSchemes {
    //     NO_PREFERENCE,
    //     DARK,
    //     LIGHT;
    // }

    private Settings settings;
    private Settings interface_settings;
    private double sunrise = -1.0;
    private double sunset = -1.0;

    private uint timer_id = 0U;

    construct {
        settings = new Settings (Config.APP_ID);
        interface_settings = new Settings ("org.gnome.desktop.interface");

        var schedule = settings.get_string ("schedule");
        if (schedule == "automatic") {
            var variant = settings.get_value ("last-coordinates");
            on_location_updated (variant.get_child_value (0).get_double (), variant.get_child_value (1).get_double ());
        }

        settings.changed["schedule"].connect (update_timer);
        update_timer ();
    }

    private void update_timer () {
        switch (settings.get_string ("schedule")) {
        case "automatic":
            get_location.begin ();
            start_timer ();
            break;
        case "manual":
            start_timer ();
            break;
        case "disabled":
            stop_timer ();
            break;
        }
    }

    private void start_timer () {
        if (timer_id != 0U)
            return;

        var timer = new TimeoutSource (1000);

        timer.set_callback (timer_callback);

        timer_id = timer.attach (null);
    }

    private void stop_timer () {
        if (timer_id == 0U)
            return;

        Source.remove (timer_id);
        timer_id = 0U;
    }

    private async void get_location () {
        try {
            var proxy = yield new GClue.Simple (Config.APP_ID, GClue.AccuracyLevel.CITY, null); // TODO: check available accuracy levels

            proxy.notify["location"].connect (() => {
                on_location_updated (
                    proxy.location.latitude, proxy.location.longitude);
            });

            on_location_updated (
                proxy.location.latitude, proxy.location.longitude);
        } catch (Error err) {
            warning (@"Failed to connect to GeoClue service: $(err.message)");
        }
    }

    private bool timer_callback () {
        var now = new DateTime.now_local ();

        double from_time, to_time;
        switch (settings.get_string ("schedule")) {
        case "automatic":
            if (sunrise >= 0 && sunset >= 0) {
                from_time = sunset;
                to_time = sunrise;
            } else {
                from_time = 20.0;
                to_time = 6.0;
            }
            break;
        case "manual":
            from_time = settings.get_double ("schedule-from-time");
            to_time = settings.get_double ("schedule-to-time");
            break;
        default:
            return true;
        }

        // var new_color_scheme = ColorScheme.NO_PREFERENCE;
        string theme;
        if (is_in_time_window (datetime_double (now), from_time, to_time))
            // new_color_scheme = ColorScheme.DARK;
            theme = "dark-gtk-theme";
        else
            theme = "light-gtk-theme";

        interface_settings.set_string ("gtk-theme", settings.get_string (theme));

        // if (new_color_scheme == settings.get_int ("color-scheme-preference"))
        //     return true;
        //
        // settings.set_int ("prefers-dark", new_color_scheme);

        return true;
    }

    private void on_location_updated (double latitude, double longitude) {
        settings.set_value (
            "last-coordinates", new Variant.tuple ({ latitude, longitude }));

        var now = new DateTime.now_local ();
        double _sunrise, _sunset;
        if (Utils.SunriseSunsetCalculator.get_sunrise_and_sunset (now, latitude, longitude, out _sunrise, out _sunset)) {
            sunrise = _sunrise;
            sunset = _sunset;
        }
    }

    public static bool is_in_time_window (double time_double, double from, double to) {
        if (from > to)
            return time_double >= from || time_double <= to;

        return time_double >= from && time_double <= to;
    }

    public static double datetime_double (DateTime datetime) {
        double time_double = 0;

        time_double += datetime.get_hour ();
        time_double += (double) datetime.get_minute () / 60;

        return time_double;
    }

}
