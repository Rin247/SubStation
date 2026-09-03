# CSRI (subtitle renderer interface).
#
# Windows-only. The libass renderer handles ASS on POSIX. The
# CSRI subproject is pulled in only when csri is enabled.
#
# Mutates `conf` and `deps` in the surrounding scope.

if not get_option('csri').disabled() and host_machine.system() == 'windows'
    conf.set('WITH_CSRI', 1)

    csri_sp = subproject('csri')
    deps += csri_sp.get_variable('csri_dep')
endif
