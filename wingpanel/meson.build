json_dep = dependency('json-glib-1.0')
libgeoclue_dep = dependency ('libgeoclue-2.0')
libwingpanel_dep = dependency('wingpanel-2.0')
indicators_dir = libwingpanel_dep.get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', libdir])

shared_module(
  meson.project_name(),
  'Backend.vala',
  'Indicator.vala',
  'MenuButton.vala',
  'ThemeController.vala',
  'Utils/SunriseSunsetCalculator.vala',
  gresource,
  dependencies: [
    config_dep,
    granite_dep,
    json_dep,
    libgeoclue_dep,
    libwingpanel_dep
  ],
  install: true,
  install_dir: indicators_dir
)
