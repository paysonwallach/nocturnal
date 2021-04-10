plug_files = files(
  'ColorSchemePane.vala',
  'Plug.vala',
  'ThemeSettings.vala'
)

switchboard_dep = dependency('switchboard-2.0')
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

shared_module(
  meson.project_name(),
  plug_files,
  plug_resources,
  include_directories: config_inc_dir,
  dependencies: [
    config_dep,
    glib_dep,
    gio_dep,
    gobject_dep,
    granite_dep,
    gtk_dep,
    switchboard_dep
  ],
  install: true,
  install_dir : join_paths(switchboard_plugsdir, 'personal')
)
