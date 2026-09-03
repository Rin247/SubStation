-- Automation 4 test file
-- Create a Macro feature, that displays some text

script_name = "Automation 4 test 1"
script_description = "Hello World in Automation 4/Lua"
script_author = "Niels Martin Hansen"
script_version = "1"


function macro_test1(subtitles, selected_lines, active_line)
	--substation.debug.out(3, "Hello World from %s", "Automation 4/Lua")
	substation.debug.out("Hello Automation 4 World!")
end

substation.register_macro("Hello", "Shows a message", macro_test1)
