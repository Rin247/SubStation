# Update-checker (libcurl).
#
# Only built when enable_update_checker is on. We pick a TLS backend
# per platform: schannel on Windows, Secure Transport on macOS,
# OpenSSL elsewhere. Other libcurl features are aggressively disabled
# to keep the link small.
#
# Mutates `deps` in the surrounding scope.

if get_option('enable_update_checker')
    curl_disable = ['tool', 'dict', 'file', 'ftp', 'gopher', 'imap', 'ldap', 'ldaps', 'mqtt', 'pop3', 'rtmp', 'rtsp', 'smb', 'smtp', 'telnet', 'tftp']
    curl_options = []
    foreach opt : curl_disable
        curl_options += opt + '=disabled'
    endforeach

    if host_machine.system() == 'windows'
        curl_options += 'schannel=enabled'
    elif host_machine.system() == 'darwin'
        curl_options += 'secure-transport=enabled'
    else
        curl_options += 'openssl=enabled'
    endif

    deps += dependency('libcurl', allow_fallback: true, default_options: curl_options)
endif
