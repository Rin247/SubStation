// Copyright (c) 2013, Thomas Goyne <plorkyeran@substation.org>
//
// Permission to use, copy, modify, and distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// SubStation Project http://www.substation.org/

#include <libsubstation/path.h>

#include <libsubstation/exception.h>
#include <libsubstation/util_osx.h>

#include <pwd.h>

#ifndef __APPLE__
#include <fstream>
#include <stdlib.h>
#include <libgen.h>
#endif

namespace {
#ifndef __APPLE__
std::string home_dir() {
	const char *env = getenv("HOME");
	if (env) return env;

	if ((env = getenv("USER")) || (env = getenv("LOGNAME"))) {
		if (passwd *user_info = getpwnam(env))
			return user_info->pw_dir;
	}

	throw agi::EnvironmentError("Could not get home directory. Make sure HOME is set.");
}
#endif  /* !__APPLE__ */
}

namespace agi {
void Path::FillPlatformSpecificPaths() {
#ifndef __APPLE__
	agi::fs::path home = home_dir();
	SetToken("?user", home/".substation");
	SetToken("?local", home/".substation");
	SetToken("?data", P_DATA);
	SetToken("?dictionary", "/usr/share/hunspell");
#else
	agi::fs::path app_support = agi::util::GetApplicationSupportDirectory();
	SetToken("?user", app_support/"SubStation");
	SetToken("?local", app_support/"SubStation");
	SetToken("?data", agi::util::GetBundleSharedSupportDirectory());
	SetToken("?dictionary", Decode("?data/dictionaries"));
#endif
	SetToken("?temp", agi::fs::path(std::filesystem::temp_directory_path()));
}

}
