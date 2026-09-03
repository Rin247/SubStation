# Install paths
#
# Produces:
#   prefix     - install root (build dir for macOS bundle, option prefix otherwise)
#   bindir     - binary install dir
#   dataroot   - data install root, always <dataroot>/substation
#   datadir    - data install dir (== dataroot)
#   localedir  - locale install dir
#   docdir     - documentation install dir
#
# On macOS, when building a .app bundle, paths are redirected into
# the bundle's Contents/ tree. Otherwise they follow the configured
# prefix and the standard GNU install dirs.

if host_machine.system() == 'darwin' and get_option('build_osx_bundle')
    prefix = meson.current_build_dir() / 'SubStation.app' / 'Contents'
    bindir = prefix / 'MacOS'
    datadir = prefix / 'SharedSupport'
    localedir = prefix / 'Resources'
    dataroot = datadir
else
    prefix = get_option('prefix')
    bindir = prefix / get_option('bindir')
    datadir = prefix / get_option('datadir')
    localedir = prefix / get_option('localedir')
    dataroot = datadir / 'substation'
endif
docdir = prefix / 'doc'
