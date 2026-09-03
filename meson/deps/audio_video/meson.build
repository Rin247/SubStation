# Optional/feature deps discovered at configure time.
#
# The check_deps table is a mini-DSL; each row is
#   [name, version, label, fallback_list, darwin_frameworks]
# If the dep is found, it's appended to `deps`, the WITH_<UPPER> macro
# is set in `conf`, and the human label is appended to `dep_avail`.
#
# Mutates the `deps` array, `conf`, and `dep_avail` in the surrounding
# scope. Sets the default audio output (`def_audio`) based on what
# was found and the `default_audio_output` option.

check_deps = [
    # audio, in order of precedence
    ['libpulse', [], 'PulseAudio', [], []],
    ['alsa', [], 'ALSA', [], []],
    ['portaudio-2.0', [], 'PortAudio', [], []],
    ['openal', '>=0.0.8', 'OpenAL', [], ['OpenAL']],
    # video
    ['ffms2', '>=2.22', 'FFMS2', ['ffms2', 'ffms2_dep'], []],
    # other
    ['fftw3', [], 'FFTW3', [], []],
    ['hunspell', [], 'Hunspell', ['hunspell', 'hunspell_dep'], []],
    ['uchardet', [], 'uchardet', ['uchardet', 'uchardet_dep'], []],
]

if host_machine.system() == 'linux'
    if cc.get_define('__WXGTK3__', dependencies: wx_defines_dep, prefix: '#include <wx/defs.h>') != ''
        check_deps += [['libportal-gtk3', [], 'libportal', [], []]]
    else
        check_deps += [['libportal', [], 'libportal', [], []]]
    endif
endif

dep_avail = []
foreach dep: check_deps
    optname = dep[0].split('-')[0]
    if not get_option(optname).disabled()
        # [provide] section is ignored if required is false;
        # must provided define fallback explicitly
        # (with meson 0.56 you can do allow_fallback: true):
        #d = dependency(dep[0], version: dep[1],
        #               required: false, allow_fallback: true)
        if dep[3].length() > 0
            d = dependency(dep[0], version: dep[1], fallback: dep[3])
        else
            d = dependency(dep[0], version: dep[1], required: false)
        endif

        if not d.found() and dep[4].length() > 0 and host_machine.system() == 'darwin'
            d = dependency('appleframeworks', modules: dep[4], required: false)
        endif

        if d.found()
            deps += d
            conf.set('WITH_@0@'.format(dep[0].split('-')[0].to_upper()), 1)
            dep_avail += dep[2]
        elif get_option(optname).enabled()
            error('@0@ enabled but not found'.format(dep[2]))
        endif
    endif
endforeach

if host_machine.system() == 'windows' and get_option('avisynth').enabled()
    conf.set('WITH_AVISYNTH', 1) # bundled separately with installer
endif

# TODO: OSS

# Pick a default audio backend from whatever we found, or fail
# loudly if the user explicitly asked for one we don't have.
def_audio = get_option('default_audio_output')
if def_audio != 'auto'
    if not dep_avail.contains(def_audio)
        error('Default audio output "@0@" selected but not available'.format(def_audio))
    endif
elif dep_avail.length() != 0
    def_audio = dep_avail[0]
else
    def_audio = ''
endif
