namespace Nocturnal {
    public class ColorSchemePane : Granite.SimpleSettingsPage {
        private Settings settings;

        public ColorSchemePane (Settings settings) {
            Object (
                title: Config.APP_NAME,
                description: "",
                activatable: true);

            this.settings = settings;

            var themes_map = ThemeSettings.get_themes_map ("themes", "gtk-3.0");

            var day_theme_label = new SummaryLabel ("Light theme");
            var day_theme_combobox = new ComboBoxText (themes_map);

            var dark_theme_label = new SummaryLabel ("Dark theme");
            var dark_theme_combobox = new ComboBoxText (themes_map);

            content_area.attach (day_theme_label, 0, 0);
            content_area.attach (day_theme_combobox, 1, 0);
            content_area.attach (dark_theme_label, 0, 1);
            content_area.attach (dark_theme_combobox, 1, 1);

            show_all ();

            settings.bind ("gtk-theme", status_switch, "state", SettingsBindFlags.DEFAULT);
            settings.bind ("light-gtk-theme", day_theme_combobox, "active_id", SettingsBindFlags.DEFAULT);
            settings.bind ("dark-gtk-theme", dark_theme_combobox, "active_id", SettingsBindFlags.DEFAULT);
        }

    }

    protected class ComboBoxText : Gtk.ComboBoxText {
        public ComboBoxText (Gee.HashMap<string, string> items) {
            set_size_request (180, 0);
            halign = Gtk.Align.START;

            foreach (var item in items.entries) {
                append (item.key, item.value);
            }
        }

    }

    protected class SummaryLabel : Gtk.Label {
        public SummaryLabel (string label) {
            Object (label: label);
        }

        construct {
            halign = Gtk.Align.END;
        }
    }
}
