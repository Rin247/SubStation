conf_pkg = configuration_data()

if host_machine.system() == 'windows'
    installer_setup = [powershell_exe,
                       '-ExecutionPolicy', 'Bypass',
                       '-File', meson.project_source_root() / 'tools/win-installer-setup.ps1']
    run_target('win-installer',
               command: [installer_setup, meson.project_build_root(), meson.project_source_root()])

    portable_setup = [powershell_exe,
                      '-ExecutionPolicy', 'Bypass',
                      '-File', meson.project_source_root() / 'packages/win_installer/portable/create-portable.ps1']
    portable_arch = host_machine.cpu_family() == 'aarch64' ? 'arm64' : 'x64'
    run_target('win-portable',
               command: [portable_setup, meson.project_build_root(), meson.project_source_root(),
                         portable_arch, meson.project_version()])
elif host_machine.system() == 'darwin'
    fontconfig_conf = run_command('pkg-config', '--variable=confdir', 'fontconfig').stdout().strip()
    bundle_app_sh = find_program(meson.project_source_root() / 'tools/osx-bundle.sh')
    run_target('osx-bundle',
               command: [bundle_app_sh, meson.project_source_root(), meson.project_build_root(), 'wx-config', fontconfig_conf, '',
                         get_option('build_osx_bundle') ? 'TRUE' : 'FALSE'])

    build_dmg_sh = find_program(meson.project_source_root() / 'tools/osx-dmg.sh')
    run_target('osx-build-dmg',
               command: [build_dmg_sh, meson.project_source_root(), meson.project_build_root(), meson.project_version()])
else
    aegisub_rdns_developer = 'org.substation'
    aegisub_rdns_name = aegisub_rdns_developer + '.SubStation'
    conf_pkg.set('AEGISUB_COMMAND', 'substation')
    conf_pkg.set('AEGISUB_RDNS_DEVELOPER', aegisub_rdns_developer)
    conf_pkg.set('AEGISUB_RDNS_NAME', aegisub_rdns_name)

    desktop_template = configure_file(input: 'desktop/substation.desktop.in.in',
                                      output: 'substation.desktop.in',
                                      configuration: conf_pkg)

    i18n = import('i18n')
    i18n.merge_file(input: desktop_template,
                    output: aegisub_rdns_name + '.desktop',
                    type: 'desktop',
                    po_dir: '../localization',
                    install: true,
                    install_dir: datadir / 'applications')

	metainfo_template = configure_file(input: 'desktop/substation.metainfo.xml.in.in',
                                      output: 'substation.metainfo.xml.in',
                                      configuration: conf_pkg)
	i18n.merge_file(input: metainfo_template,
                    output: aegisub_rdns_name + '.metainfo.xml',
                    type: 'xml',
                    po_dir: '../localization',
                    install: true,
                    install_dir: datadir / 'metainfo')

    aegisub_logos = ['16x16.png', '22x22.png', '24x24.png', '32x32.png', '48x48.png', '64x64.png', 'scalable.svg']

    foreach s: aegisub_logos
        dir = s.split('.')[0]
        ext = s.split('.')[1]
        install_data('desktop' / dir / 'substation.' + ext,
                     rename: aegisub_rdns_name + '.' + ext,
                     install_dir: datadir / 'icons' / 'hicolor' / dir / 'apps')
    endforeach
endif
