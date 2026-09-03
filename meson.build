project('SubStation', ['c', 'cpp'],
        license: 'BSD-3-Clause',
        meson_version: '>=0.60.0',
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

# Subprojects / source trees that produce target/library files
# referenced by meson/target. Order matters: libsubstation depends
# on the deps/ conf state; src/ depends on libsubstation's include
# dirs and libresrc.
subdir('automation')
subdir('libsubstation')
subdir('packages')
subdir('po')
subdir('src')
if get_option('tests')
    subdir('tests')
    subdir('automation/tests')
endif

# Finally, link the executable.
subdir('meson/target')
