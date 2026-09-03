# Linux-specific build bits.
#
# Currently just a placeholder for non-Windows, non-macOS POSIX
# (which is Linux for the platforms we ship). Fontconfig is pulled
# in here; if any BSD- or Solaris-specific logic shows up, this is
# where it should go.
#
# Mutates `deps` and `conf` in the surrounding scope.

if host_machine.system() == 'linux'
    # libportal is added by deps/audio_video after wx is known
    # (libportal-gtk3 vs libportal depending on wxGTK3). All other
    # Linux-specific deps are picked up via deps/core / deps/audio_video.
endif
