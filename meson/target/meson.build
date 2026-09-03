# Build target (executable + manifest + PCH).
#
# This file is the bottom of the build pipeline. It assumes all of
# the dep discovery in deps_*.build, platform_*.build, and
# config_data.build has already happened, and that
# `automation`, `libsubstation`, `packages`, `po`, and `src` have
# all been subdir()'d in (in that order) by the top-level meson.build.
#
# The names on the left (substation_src, libresrc, libsubstation,
# etc.) are populated by the corresponding subdir()'d meson.build
# files.

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
                     include_directories: [libsubstation_inc, libresrc_inc, version_inc, include_directories(meson.project_source_root() / 'src')],
                     cpp_pch: substation_cpp_pch,
                     c_pch: substation_c_pch,
                     install: true,
                     install_dir: bindir,
                     dependencies: deps,
                     win_subsystem: 'windows')
