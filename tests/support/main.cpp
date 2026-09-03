// Copyright (c) 2010, Amar Takhar <verm@substation.org>
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

#include <gtest/gtest.h>

#include <libsubstation/dispatch.h>
#include <libsubstation/fs.h>
#include <libsubstation/log.h>
#include <libsubstation/util.h>

#include <cstdlib>
#include <ctime>

int main(int argc, char **argv) {
	agi::dispatch::Init([](agi::dispatch::Thunk) { });
	agi::util::InitLocale();

	agi::log::log = new agi::log::LogSink;
	agi::log::log->Subscribe(std::make_unique<agi::log::JsonEmitter>("./"));
	::testing::InitGoogleTest(&argc, argv);

	srand(time(nullptr));

	int retval = RUN_ALL_TESTS();

	delete agi::log::log;

	return retval;
}

