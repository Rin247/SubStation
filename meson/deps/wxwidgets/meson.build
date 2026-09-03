# wxWidgets discovery.
#
# Tries system wxWidgets first; falls back to building wxWidgets as
# a CMake subproject. Either way, exposes:
#   wx_dep         - usable dependency object for the main app
#   wx_defines_dep - dependency with just compile args + includes
#                    (needed when wx is a subproject, because meson
#                     can't extract defines from a library whose
#                     sources are being built)
#
# Mutates `deps` and `conf` in the surrounding scope.

wx_dep = dependency('wxWidgets', version: '1.0.0' + get_option('wx_version'),
                    required: false,
                    modules: ['std', 'stc', 'gl'])

if wx_dep.found()
    deps += wx_dep
    wx_defines_dep = wx_dep
else
    build_shared = true
    if get_option('default_library') == 'static'
        build_shared = false
    endif
    build_type = 'Release'
    if get_option('buildtype') == 'debug'
        build_type = 'Debug'
    endif

    opt_var = cmake.subproject_options()
    opt_var.set_override_option('cpp_std', 'c++20')
    opt_var.add_cmake_defines({
        'CMAKE_POLICY_VERSION_MINIMUM': '3.31',

        'wxBUILD_INSTALL': false,
        'wxBUILD_PRECOMP': 'OFF',       # otherwise breaks project generation w/ meson
        'wxBUILD_SHARED': build_shared,
        'CMAKE_POSITION_INDEPENDENT_CODE': true,

        'wxUSE_WEBVIEW': false,         # breaks build on linux
        'CMAKE_BUILD_TYPE': build_type,
        'wxUSE_IMAGE': true,
        'wxBUILD_MONOLITHIC': true      # otherwise breaks project generation w/ meson
    })

    wx = cmake.subproject('wxWidgets', options: opt_var)

    deps += wx.dependency('wxmono')
    foreach cmake_target: ['wxregex', 'wxscintilla', 'wxlexilla']
        if wx.target_list().contains(cmake_target)
            deps += wx.dependency(cmake_target)
        endif
    endforeach

    # The wxWidgets cmake subproject doesn't propagate all of its glib/gtk
    # transitive dependencies to meson. Add them explicitly on Linux so the
    # final link line includes the libraries. Without these, symbols like
    # g_utf8_collate(), gdk_pixbuf_get_rowstride(), etc. remain unresolved
    # when using the bundled wxWidgets on a stock Ubuntu runner that doesn't
    # have a system libwxgtk3.0-gtk3-dev satisfying the >=3.3.0 requirement.
    if host_machine.system() == 'linux'
        foreach lib : ['glib-2.0', 'gobject-2.0', 'gmodule-2.0', 'gdk-pixbuf-2.0']
            d = dependency(lib, required: false)
            if d.found()
                deps += d
            endif
        endforeach
    endif

    # meson doesn't let you get defines from a library that has sources which need to be built,
    # but allows it if you use partial_dependency() to get only includes and compile args.
    wx_defines_dep = wx.dependency('wxmono').partial_dependency(compile_args: true, includes: true)

    if host_machine.system() == 'windows' or host_machine.system() == 'darwin'
        deps += [
            wx.dependency('wxpng'),
        ]
    endif

    if host_machine.system() == 'windows'
        deps += [
            wx.dependency('wxzlib'),
            wx.dependency('wxexpat'),
        ]

        if cc.has_header('rpc.h')
            deps += cc.find_library('rpcrt4', required: true)
        else
            error('Missing Windows SDK RPC Library (rpc.h / rpcrt4.lib)')
        endif
        if cc.has_header('commctrl.h')
            deps += cc.find_library('comctl32', required: true)
        else
            error('Missing Windows SDK Common Controls Library (commctrl.h / comctl32.lib)')
        endif
    endif

    conf.set('WITH_INTERNAL_WXWIDGETS', 1)
endif
