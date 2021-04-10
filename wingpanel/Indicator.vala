/*
 * Nocturnal
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 */

public class Nocturnal.Indicator : Wingpanel.Indicator {
    private Gtk.Image icon;
    private Gtk.Grid menu;

    private Backend backend;
    private ThemeController theme_controller;

    public Indicator () {
        Object (
            code_name: "nocturnal");
    }

    construct {
        icon = new Gtk.Image.from_icon_name (
            "nocturnal-symbolic",
            Gtk.IconSize.SMALL_TOOLBAR);

        theme_controller = new ThemeController ();
        backend = new Backend ();

        icon.button_press_event.connect ((event) => {
            if (event.button == Gdk.BUTTON_MIDDLE) {
                theme_controller.toggle_state ();

                return Gdk.EVENT_STOP;
            }

            return Gdk.EVENT_PROPAGATE;
        });
        construct_menu ();

        visible = true;
    }

    private void construct_menu () {
        var mode_switch = new Granite.Widgets.ModeButton ();

        mode_switch.set_border_width (12);

        mode_switch.append_text ("Light");
        mode_switch.append_text ("Dark");

        mode_switch.selected = theme_controller.get_state () == ThemeController.State.LIGHT ? 0 : 1;
        mode_switch.mode_changed.connect (() => {
            theme_controller.toggle_state ();
        });

        var settings = new Settings (Config.APP_ID);
        var toggle_switch = new Wingpanel.Widgets.Switch ("Automatic", settings.get_string ("schedule") == "automatic");

        toggle_switch.get_label ()
            .get_style_context ()
            .add_class (Granite.STYLE_CLASS_H4_LABEL);
        toggle_switch.switched.connect (() => {
            settings.set_string ("schedule", toggle_switch.active ? "automatic" : "disabled");
        });
        toggle_switch.bind_property ("active", mode_switch, "sensitive", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);

        var settings_button = new MenuButton ("Settings");

        settings_button.clicked.connect (() => {
            close ();

            try {
                AppInfo.launch_default_for_uri ("settings://nocturnal", null);
            } catch (Error e) {
                warning ("%s\n", e.message);
            }
        });

        menu = new Gtk.Grid ();

        menu.attach (mode_switch, 0, 0);
        menu.attach (toggle_switch, 0, 1);
        menu.attach (new Wingpanel.Widgets.Separator (), 0, 2);
        menu.attach (settings_button, 0, 3);
    }

    public override Gtk.Widget get_display_widget () {
        return icon;
    }

    public override Gtk.Widget? get_widget () {
        return menu;
    }

    public override void opened () {}

    public override void closed () {}

    private File get_state_file () {
        return File.new_build_filename (
            Environment.get_user_data_dir (),
            @"last-state-$(Config.DATA_VERSION)");
    }

    private void save_state () {
        File state_file = get_state_file ();

        var generator = new Json.Generator ();
        var root = new Json.Node (Json.NodeType.OBJECT);
        var root_object = new Json.Object ();

        root.set_object (root_object);
        generator.set_root (root);

        try {
            OutputStream state_stream = state_file.replace (null, false, FileCreateFlags.NONE);
            generator.to_stream (state_stream);
        } catch (Error err) {
            warning (@"unable to write state to file: $(err.message)");
        }
    }

    private void load_state (out DateTime? sunrise, out DateTime? sunset) {
        File state_file = get_state_file ();

        if (!state_file.query_exists ()) {
            return;
        }

        Json.Parser parser = new Json.Parser ();

        try {
            InputStream state_stream = state_file.read ();

            parser.load_from_stream (state_stream);
        } catch (Error err) {
            warning (@"unable to read from state file: $(err.message)");
        }

        Json.Node? root = parser.get_root ();

        if (root == null) {
            return;
        }

        Json.Object root_object = root.get_object ();
    }

}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION)
        return null;

    var indicator = new Nocturnal.Indicator ();

    return indicator;
}
