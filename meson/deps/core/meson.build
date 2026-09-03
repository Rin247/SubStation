# Core C/C++ deps that are always required.
#
# `cxx` and `cc` are defined at the top-level meson.build before any
# platform/ or deps/ subdir runs (because meson/platform/windows
# uses `cc.find_library()` for DirectSound).
#
# Mutates the `deps` array in the surrounding scope.

deps += cc.find_library('m', required: false)
deps += cc.find_library('dl', required: false)

deps += dependency('iconv', fallback: ['iconv', 'libiconv_dep'])

deps += dependency('libass', version: '>=0.17.5',
                   fallback: ['libass', 'libass_dep'])

# Boost: prefer system, fall back to bundled subproject. Boost has a
# long history of packaging surprises (regex module, static-link
# transitive deps) so we handle them explicitly.
boost_static = meson.version().version_compare('>=0.63.0') and get_option('prefer_static')    # boost dependencies do not respect prefer_static https://github.com/mesonbuild/meson/issues/15458
boost_modules = ['chrono', 'locale']

if boost_static
    boost_modules += 'thread'   # static boost dependencies do not include transitive dependencies https://github.com/mesonbuild/meson/issues/15457
endif

if not get_option('local_boost')
    boost_dep = dependency('boost', version: '1.0.0',
                            modules: boost_modules,
                            required: false,
                            static: boost_static)

    if boost_dep.version().version_compare('<1.77.0')
        # boost regex is header-only since version 1.77.0, and some distributions have stopped shipping the stub module since then.
        # So we need to require boost.regex for older versions but can't require it for newer versions.
        boost_dep = dependency('boost', version: '1.0.0',
                                modules: boost_modules + ['regex'],
                                required: false,
                                static: boost_static)
    endif
endif

if get_option('local_boost') or not boost_dep.found()
    boost_dep = []
    boost = subproject('boost')
    foreach module: (boost_modules + ['regex'])
        boost_dep += boost.get_variable('boost_' + module + '_dep')
    endforeach
endif

if cc.get_argument_syntax() == 'gcc'
  # Work around compile error in Boost GIL, can be removed once
  # https://github.com/boostorg/gil/commit/2956a0e9ef71f5c4f3163c8b8d675679e0fbaaff
  # is in a boost release that's available everywhere
  add_project_arguments(cc.get_supported_arguments(['-Wno-missing-template-arg-list-after-template-kw']), language: 'cpp')
endif

deps += boost_dep
if host_machine.system() == 'windows'
    conf.set('BOOST_USE_WINDOWS_H', 1)
endif

deps += dependency('zlib')

deps += dependency('icu-uc', version: '>=4.8.1.1')
deps += dependency('icu-i18n', version: '>=4.8.1.1')
