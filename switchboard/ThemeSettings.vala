public class Nocturnal.ThemeSettings {
    private static Gee.List<string> get_themes (string path, string condition) {
        var themes = new Gee.ArrayList<string> ();

        string[] dirs = {
            Path.build_filename (Path.DIR_SEPARATOR_S, "usr", "share", path),
            Path.build_filename (Environment.get_user_data_dir (), path)
        };

        foreach (var dir in dirs) {
            debug (@"searching $dir");
            var file = File.new_for_path (dir);

            if (!file.query_exists ())
                continue;

            try {
                var enumerator = file.enumerate_children (FileAttribute.STANDARD_NAME, 0);

                FileInfo file_info;
                while ((file_info = enumerator.next_file ()) != null) {
                    var name = file_info.get_name ();
                    var check_theme = File.new_build_filename (dir, name, condition);
                    var check_icons = File.new_build_filename (dir, name, "48x48", condition);
                    if ((check_theme.query_exists ()
                         || check_icons.query_exists ())
                        && name != "Emacs"
                        && name != "default"
                        && !themes.contains (name))
                        themes.add (name);
                }
            } catch (Error e) {
                warning (e.message);
            }
        }

        return themes;
    }

    public static Gee.HashMap<string, string> get_themes_map (string path, string condition) {
        var themes = get_themes (path, condition);
        var map = new Gee.HashMap<string, string> ();

        foreach (var theme in themes)
            map.set (theme, theme);

        return map;
    }

}
