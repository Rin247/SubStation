-- Automation 4 test file
-- Create a Macro feature, that displays some text

script_name = "Automation 4 test 4"
script_description = "Test progress reporting"
script_author = "Niels Martin Hansen"
script_version = "1"


function wait()
	local s = ""
	for i = 0, 500 do
		s = s .. i
	end
	return s
end

function progression(subtitles, selected_lines, active_line)
	while not substation.progress.is_cancelled() do
		substation.progress.task("Counting up...")
		for i = 0, 100, 0.2 do
			substation.progress.set(i)
			if substation.progress.is_cancelled() then
				break
			end
			wait()
		end
		if substation.progress.is_cancelled() then
			break
		end
		substation.progress.task("Counting down...")
		for i = 0, 100 do
			substation.progress.set(100-i)
			wait()
		end
	end
end


substation.register_macro("Progress fun", "Does absolutely nothing", progression, nil)
