# OpenGL.
#
# Found by pkg-config first, then by platform-specific library
# names, then by header probe. Sets HAVE_OPENGL_GL_H on macOS (no
# GL/glext.h) and HAVE_GL_GLEXT_H on other platforms. Fails
# loudly if nothing usable is found.
#
# Mutates `deps` and `conf` in the surrounding scope.

dep_gl = dependency('gl', required: false)
if not dep_gl.found()
    if host_machine.system() == 'windows'
        dep_gl = cc.find_library('opengl32', required: false)
    else
        dep_gl = cc.find_library('GL', required: false)
    endif

    if not cc.has_header('GL/gl.h')
        dep_gl = dependency('', required: false)
    endif
endif
if host_machine.system() == 'darwin'
    conf.set('HAVE_OPENGL_GL_H', 1)
else
    conf.set('HAVE_GL_GLEXT_H', cc.has_header('GL/glext.h'))
endif

if not dep_gl.found()
    error('OpenGL implementation not found')
endif

deps += dep_gl
