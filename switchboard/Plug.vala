public class Nocturnal.Plug : Switchboard.Plug {
    private Settings settings = new Settings (Config.APP_ID);
    private ColorSchemePane color_scheme_pane;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);

        settings.set ("nocturnal", null);

        Object (
            category: Category.PERSONAL,
            code_name: Config.APP_ID,
            display_name: Config.APP_NAME,
            description: "",
            icon: "nocturnal",
            supported_settings: settings);
    }

    construct {
        Gtk.IconTheme.get_default ()
            .add_resource_path ("/com/paysonwallach/nocturnal/icons");
    }

    public override Gtk.Widget get_widget () {
        if (color_scheme_pane == null)
            color_scheme_pane = new ColorSchemePane (settings);

        return color_scheme_pane;
    }

    public override void shown () { }

    public override void hidden () { }

    public override void search_callback (string location) { }

    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> ();

        search_results.set (@"$(display_name) → Nocturnal", "nocturnal");

        return search_results;
    }

}

public Switchboard.Plug get_plug (Module module) {
    var plug = new Nocturnal.Plug ();
    return plug;
}
