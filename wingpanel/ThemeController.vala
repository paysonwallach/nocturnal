/*
 * Nocturnal
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 */

namespace Nocturnal {
    public class ThemeController {
        const string GTK_SCHEMA_KEY = "org.gnome.desktop.interface";
        const string GTK_THEME_KEY = "gtk-theme";

        private Settings gtk_settings;
        private Settings nocturnal_settings;

        public enum State {
            LIGHT,
            DARK;
        }

        public ThemeController () {
            gtk_settings = new Settings (GTK_SCHEMA_KEY);
            nocturnal_settings = new Settings (Config.APP_ID);
        }

        public State get_state () {
            return gtk_settings.get_string (GTK_THEME_KEY) == nocturnal_settings.get_string ("light-gtk-theme") ? State.LIGHT : State.DARK;
        }

        public void toggle_state () {
            var gtk_theme = get_state () == State.LIGHT ? "dark-gtk-theme" : "light-gtk-theme";
            gtk_settings.set_string (
                GTK_THEME_KEY,
                nocturnal_settings.get_string (gtk_theme));
        }

    }
}
