-- Automation 4 test file
-- Create a Filter feature that does some kara stuff

script_name = "Automation 4 test 10"
script_description = "Test reaction to export filter name clashes"
script_author = "Niels Martin Hansen"
script_version = "1"

include("utils.lua")

function function1(subtitles, config)
	substation.debug.out("function 1")
end
function function2(subtitles, config)
	substation.debug.out("function 2")
end

substation.register_filter("Export breaker", "Export filter with nameclash (1)", 500, function1)
substation.register_filter("Export breaker", "Export filter with nameclash (2)", 500, function2)
