project(
  'com.paysonwallach.nocturnal',
  'vala', 'c',
  version: '0.1.0'
)

gnome = import('gnome')
vala = meson.get_compiler('vala')

prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
libdir = join_paths(prefix, get_option('libdir'))

vapi_dir = join_paths(meson.source_root(), 'vapi')

gio_dep = dependency('gio-2.0')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
granite_dep = dependency('granite', version: '>=5.5.0')
gtk_dep = dependency('gtk+-3.0', version: '>= 3.22')

conf = configuration_data()
conf.set_quoted('APP_NAME', 'Nocturnal')
conf.set_quoted('APP_ID', meson.project_name())
conf.set_quoted('DATA_VERSION', '1')

config_h = configure_file(
  output: 'config.h',
  configuration: conf
)

config_inc_dir = include_directories('.')

config_dep = declare_dependency(
  dependencies: vala.find_library('config', dirs: vapi_dir),
  sources: config_h
)

gresource = gnome.compile_resources(
  'nocturnal-resources',
  join_paths('data', meson.project_name() + '.gresource.xml'),
  source_dir: 'data',
  c_name: 'nocturnal'
)

plug_resources = gnome.compile_resources(
  'plug_resources',
  join_paths('data', meson.project_name() + '.gresource.xml'),
  source_dir: 'data'
)

add_project_arguments([
    '-DG_LOG_DOMAIN="@0@"'.format(meson.project_name())
  ],
  language: 'c'
)

subdir('data')
subdir('switchboard')
subdir('wingpanel')

meson.add_install_script('meson/post_install.py')
