# macOS-specific build bits.
#
#   - Pulls in Objective-C/C++ for the .mm files
#   - Silences the GL deprecation warnings (Apple deprecated OpenGL
#     in 10.14 but it's still the only option on older systems)
#   - Adds the Apple frameworks used by libsubstation/src (CoreText,
#     CoreFoundation, AppKit, Carbon, IOKit, QuartzCore, plus
#     optional ScreenCaptureKit)
#   - Defines WITH_FONTCONFIG on non-Windows POSIX systems (Linux
#     picks it up in platform_linux.build; macOS is included here)
#
# Mutates `deps` and `conf` in the surrounding scope.

if host_machine.system() == 'darwin'
    add_languages('objc', 'objcpp')
    add_project_arguments('-DGL_SILENCE_DEPRECATION', language: 'cpp')
    # meson neither supports objcpp_std nor inherits cpp_std https://github.com/mesonbuild/meson/issues/5495
    add_project_arguments('-std=c++20', language: 'objcpp')
elif host_machine.system() != 'windows'
    conf.set('WITH_FONTCONFIG', 1)
    deps += dependency('fontconfig')
endif

if host_machine.system() == 'darwin'
    deps += dependency('appleframeworks', modules : ['CoreText', 'CoreFoundation', 'AppKit', 'Carbon', 'IOKit', 'QuartzCore'])
    deps += dependency('appleframeworks', modules : ['ScreenCaptureKit'], required : false)
endif
