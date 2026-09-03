# LuaJIT discovery.
#
# LuaJIT must be compiled in 5.2 mode (for Lua 5.2 compat). We try the
# system pkg-config one first; if found, we run a small test program
# that fails on a non-5.2 LuaJIT. If that fails, or system_luajit is
# false, we fall back to the bundled subproject.
#
# Mutates `deps` and `luajit` in the surrounding scope.

luajit = dependency('luajit', version: '1.0.0', required: get_option('system_luajit'),
                    allow_fallback: false, method: 'pkg-config')
if luajit.found() and luajit.type_name() != 'internal'
    luajit_test = cc.run(files('tests/tests/luajit_52.c'), dependencies: luajit)

    if luajit_test.returncode() != 0
        if get_option('system_luajit')
            error('System luajit found but not compiled in 5.2 mode')
        else
            message('System luajit found but not compiled in 5.2 mode')
            luajit = dependency('', required: false)
        endif
    else
        deps += luajit
    endif
endif

if not luajit.found()
    message('Using built-in luajit')
    subproject('luajit') # Initialize subproject to ignore system luajit
    luajit = dependency('luajit')
    assert(luajit.type_name() == 'internal', 'System luajit used instead of built-in luajit')
endif

if luajit.type_name() == 'internal'
    deps += luajit
endif

deps += subproject('luabins').get_variable('luabins_dep')
