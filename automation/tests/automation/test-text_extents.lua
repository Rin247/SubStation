-- Automation 4 test file
-- Test the result of the text_extents function

script_name = "Test text_extents"
script_description = "Test what the result of text_extents is on a fixed string on all styles in the file"
script_author = "Niels Martin Hansen"
script_version = "1"


function test_te(subtitles, selected_lines, active_line)
	local teststring = "Test"
	
	substation.debug.out("Test string is '" .. teststring .. "'\n")
	
	local styles = {}
	for i = 1, #subtitles do
		local l = subtitles[i]
		if l.class == "style" then
			substation.debug.out(" - - -\n")
			substation.debug.out("Found style: " .. l.name .. "\n")
			local width, height, descent, extlead = substation.text_extents(l, teststring)
			substation.debug.out(string.format("Width: %.2f  Height: %.2f  Descent: %.2f  Ext. lead: %.2f\n", width, height, descent, extlead))
		end
		substation.progress.set(i/#subtitles*100)
	end
end


substation.register_macro("Test text_extents", "Show the result of the text_extents function for all styles in the file", test_te, nil)
