# Windows-specific build bits.
#
#   - Compiler flags (UNICODE, NOMINMAX, _WIN32_WINNT)
#   - CSRI_NO_EXPORT when csri is enabled (to avoid DLL export issues
#     in the CSRI subproject)
#   - nasm fallback (either via the bundled subproject or system nasm)
#   - PowerShell host for the version + installer scripts
#   - DirectSound (optional)
#   - DWrite 3 feature probe
#
# Mutates `deps`, `conf`, `nasm`, and `powershell_exe` in the
# surrounding scope. Also appends to `dep_avail` when DirectSound
# is available.

if host_machine.system() == 'windows'
    # The CRT must be linked dynamically (the default): the automation code
    # assumes the app and LuaJIT's ffi.C use the same CRT, which doesn't hold
    # when the CRT is statically linked.
    # Use a configurable WIN32 target value so modern toolchains can target
    # recent Windows SDKs (default is 0x0A00 = Windows 10).
    add_project_arguments('-DUNICODE', '-DNOMINMAX', '-D_WIN32_WINNT=' + get_option('windows_target'), language: 'cpp')

    if not get_option('csri').disabled()
        add_global_arguments('-DCSRI_NO_EXPORT', language: 'c')
    endif

    if get_option('fallback_nasm') or \
       not find_program('nasm', required: false).found()
        nasm = subproject('nasm').get_variable('nasm')
        meson.override_find_program('nasm', nasm)
    endif
endif

if host_machine.system() == 'windows'
    powershell_exe = find_program('powershell')
    version_sh = [powershell_exe,
                  '-ExecutionPolicy', 'Bypass',
                  '-File', meson.project_source_root() / 'tools' / 'version.ps1']
else
    version_sh = find_program(meson.project_source_root() / 'tools' / 'version.sh')
endif
version_h = custom_target('git_version.h',
                          command: [version_sh, meson.current_build_dir(), meson.project_source_root()],
                          build_by_default: true,
                          build_always_stale: true, # has internal check whether target file will be refreshed
                          output: ['git_version.h'])

meson.add_dist_script(version_sh, meson.current_build_dir(), meson.project_source_root(), 'dist')

if host_machine.system() == 'windows' and not get_option('directsound').disabled()
    dsound_dep = cc.find_library('dsound', required: get_option('directsound'))
    winmm_dep = cc.find_library('winmm', required: get_option('directsound'))
    ole32_dep = cc.find_library('ole32', required: get_option('directsound'))
    have_dsound_h = cc.has_header('dsound.h')
    if not have_dsound_h and get_option('directsound').enabled()
        error('DirectSound enabled but dsound.h not found')
    endif

    dxguid_dep = cc.find_library('dxguid', required: true)
    if dsound_dep.found() and winmm_dep.found() and ole32_dep.found() and dxguid_dep.found() and have_dsound_h
        deps += [dsound_dep, winmm_dep, ole32_dep, dxguid_dep]
        conf.set('WITH_DIRECTSOUND', 1)
        dep_avail = ['DirectSound'] + dep_avail
    endif
endif

if host_machine.system() == 'windows' and cc.has_header('dwrite_3.h')
    conf.set('HAVE_DWRITE_3', 1)
endif
