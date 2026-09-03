# Build-time configuration_data.
#
# Produces:
#   conf         - configuration_data with WITH_* feature macros
#   conf_defines - flattened `-DKEY=value` strings (used when
#                  b_pch is off, to avoid bloating the PCH)
#   conf_meson   - configuration_data with DEFAULT_PLAYER_AUDIO
#                  (consumed by the executable via a generated header)
#   substation_order_dep - configure_file that writes acconf.h
#                  (used when b_pch is on, to keep PCH small)
#   substation_defines   - compiler defines for the executable
#
# The `conf` and `conf_meson` objects are intentionally kept
# separate so consumer code can read whichever it needs.
#
# Mutates the surrounding scope's `conf`, `conf_defines`,
# `conf_meson`, `substation_order_dep`, `substation_defines`.

conf = configuration_data()
conf.set_quoted('P_DATA', dataroot)
conf.set_quoted('P_LOCALE', localedir)
if get_option('credit') != ''
    conf.set_quoted('BUILD_CREDIT', get_option('credit'))
endif
if get_option('official_release')
    conf.set('AEGI_OFFICIAL_RELEASE', 1)
endif
conf.set('WITH_UPDATE_CHECKER', get_option('enable_update_checker'))
if get_option('enable_update_checker')
    conf.set_quoted('UPDATE_CHECKER_SERVER', get_option('update_server'))
    conf.set_quoted('UPDATE_CHECKER_BASE_URL', get_option('update_url'))
endif

# alloca() detection. The code uses alloca() in a few places and
# already includes <stdlib.h> unconditionally; we only need to set
# flags for the older MSVC intrinsic form.
if cc.has_function('alloca', prefix: '#include <stdlib.h>')
    # The files using alloca() already include <stdlib.h> unconditionally.
elif cc.has_function('alloca', prefix: '#include <alloca.h>')
    conf.set('HAVE_ALLOCA_H', true)
elif cc.has_header_symbol('malloc.h', '_alloca', prefix: '#include <stdlib.h>')
    # cc.has_function() can't find _alloca() intrinsic on cl.exe,
    # so we use cc.has_header_symbol().
    conf.set('HAVE_MALLOC_H', true)
    conf.set('HAVE_UNDERLINE_ALLOCA', true)
elif cc.has_header_symbol('malloc.h', 'alloca', prefix: '#include <stdlib.h>')
    # clang-cl.exe has the wrong name for cl.exe's _alloca()
    conf.set('HAVE_MALLOC_H', true)
endif

# the configuration_data as compiler flags
conf_defines = []
foreach key : conf.keys()
    # Some hacks since meson apparently can't give you the type of a variable
    if '@0@'.format(conf.get(key)) == 'true'
        assert(conf.get(key) == true)
        conf_defines += '-D@0@'.format(key)
    elif '@0@'.format(conf.get(key)) != 'false'
        # conf.set() with a string quotes the string so conf.get(key) can't be the actual string 'false'
        conf_defines += '-D@0@=@1@'.format(key, conf.get(key))
    endif
endforeach

substation_order_dep = []
substation_defines = []

if get_option('b_pch')
    # Write the feature flags into a configure_file to not bloat the compiler args too much
    substation_order_dep += configure_file(output: 'acconf.h', configuration: conf)
else
    # Manually pass the feature flags as compiler args
    substation_defines += conf_defines

    if host_machine.system() == 'windows'
        # This is also part of all the PCHs
        substation_defines += '-DWIN32_LEAN_AND_MEAN'
    endif
endif

conf_meson = configuration_data()
conf_meson.set('DEFAULT_PLAYER_AUDIO', def_audio)
