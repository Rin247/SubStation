project('SubStation', ['c', 'cpp'],
        license: 'BSD-3-Clause',
        meson_version: '>=0.64.0',
        default_options: [
            'cpp_std=c++20',
            'warning_level=3',
            'buildtype=debugoptimized',
            'b_ndebug=if-release',

            'harfbuzz:icu=disabled',
            'ffmpeg:libdav1d=enabled',
            'luajit:default_library=static',
            'luajit:amalgam=true',
            'luajit:lua52compat=true',
            'luajit:luajit=false',
        ],
        version: '1.0.0')

cmake = import('cmake')

# 64-bit-only: x86_64 (Windows, Linux, macOS) and aarch64 (Apple
# Silicon, Linux ARM). 32-bit x86, 32-bit ARM, and any other
# architectures are unsupported. The renderer, the LuaJIT FFI
# surface, and the bundled libraries all assume 64-bit pointers.
supported_arches = ['x86_64', 'aarch64']
if not supported_arches.contains(host_machine.cpu_family())
    error('Unsupported CPU architecture: @0@. SubStation only supports 64-bit targets (@1@).'.format(
          host_machine.cpu_family(), ', '.join(supported_arches)))
endif

# MSVC sets this automatically with -MDd, but it has a different meaning on other platforms
if get_option('debug') and host_machine.system() != 'windows'
    add_project_arguments('-D_DEBUG', language: 'cpp')
endif

# Shared state for the rest of the build system.
#
# `conf` is built up incrementally as we discover optional deps and
# platform features. `deps` is the master dependency list. We
# initialize both here and rely on the per-concern files in meson/
# to mutate them.
conf = configuration_data()
deps = []
# dep_avail holds the human labels of optional deps that were found
# (e.g. 'PulseAudio', 'ALSA'). Initialized here so the platform/
# files can append to it (DirectSound does this) before deps/audio_video
# has had a chance to populate it.
dep_avail = []

# Compiler handles. Defined here (not in meson/deps/core) because
# the platform/*.build files reference them: meson/platform/windows
# uses `cc.find_library()` for DirectSound and `cc.has_header()` for
# the DWrite 3 probe, both of which fire before deps/core runs.
cxx = meson.get_compiler('cpp')
cc = meson.get_compiler('c')

# Include dir for the project root. Used by the version custom
# target and the SubStation include path resolution. Declared
# here (top-level) because include_directories() in a subdir
# can't reach the project root without an absolute path, which
# meson rejects for relocatable builds.
version_inc = include_directories('.')

# Per-concern meson/ scripts, in dependency order. Each one
# assumes the previous ones have run.
subdir('meson/paths')
subdir('meson/platform/linux')
subdir('meson/platform/darwin')
subdir('meson/platform/windows')
subdir('meson/deps/core')
subdir('meson/deps/wxwidgets')
subdir('meson/deps/audio_video')
subdir('meson/deps/opengl')
subdir('meson/deps/lua')
subdir('meson/deps/update_checker')
subdir('meson/deps/csri')
subdir('meson/config_data')

# Build substation_order_dep / substation_defines from the conf
# data that meson/config_data just assembled. This has to live at
# the top level (not in meson/config_data) because configure_file()
# writes to the current build dir, and the C++ PCH includes
# '../acconf.h' relative to libsubstation/include/ — that resolves
# to <build>/acconf.h, which is only true when configure_file runs
# at the top level.
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

# Subprojects / source trees that produce target/library files.
# Order matters: libsubstation depends on the deps/ conf state;
# src/ depends on libsubstation's include dirs and libresrc.
subdir('automation')
subdir('libsubstation')
subdir('packages')
subdir('localization')
subdir('src')
if get_option('tests')
    subdir('tests')
    subdir('automation/tests')
endif

# Build the SubStation executable. Declared here at the top level
# (not in a subdir) because the paths it references — 'src/...',
# 'libsubstation/...' — are project-root-relative. Inside a subdir
# they'd have to be '..' chains, and include_directories() rejects
# absolute paths from meson.project_source_root(). Keeping it at
# the top level avoids both problems.
substation_cpp_pch = ['src/include/agi_pre.h']
substation_c_pch = ['src/include/agi_pre_c.h']

link_args = []
link_depends = []
if host_machine.system() == 'windows'
    manifest_file = configure_file(copy: true, input: 'src/res/substation.exe.manifest', output: 'substation.exe.manifest')
    link_args += ['/MANIFEST:EMBED', '/MANIFESTINPUT:@0@'.format(manifest_file)]
    link_depends += manifest_file
endif

substation = executable('substation', substation_src, version_h, resrc, substation_order_dep,
                        c_args: substation_defines,
                        cpp_args: substation_defines,
                        link_with: [libresrc, libsubstation],
                        link_args: link_args,
                        link_depends: link_depends,
                        include_directories: [libsubstation_inc, libresrc_inc, version_inc, include_directories('src')],
                        cpp_pch: substation_cpp_pch,
                        c_pch: substation_c_pch,
                        install: true,
                        install_dir: bindir,
                        dependencies: deps,
                        win_subsystem: 'windows')
