-- Automation 4 test file
-- Create a Filter feature that does some kara stuff

script_name = "Automation 4 test 6"
script_description = "Test basic export filters"
script_author = "Niels Martin Hansen"
script_version = "1"

include("utils.lua")


function test6_2(subtitles, config)
	--[[for i = 1, #subtitles do
		local l = subtitles[i]
		if l.class == "dialogue" then
			local nl = table.copy(l)
			nl.text = "Copied!"
			subtitles.insert(i, nl)
			break
		end
	end]]
end


function test6(subtitles, config)
	substation.progress.task("Collecting style data")
	local styles = {}
	for i = 1, #subtitles do
		substation.debug.out("finding styles, line " .. i)
		local l = subtitles[i]
		if l.class == "dialogue" then
			break
		end
		if l.class == "style" then
			substation.debug.out("    found style: " .. l.name)
			styles[l.name] = l
		end
		substation.progress.set(100 * i / #subtitles)
	end
	
	local res = {}
	
	local i = 1
	while i <= #subtitles do
		substation.debug.out("producing effect, line " .. i)
		local l = subtitles[i]
		if l.class == "dialogue" then
			substation.debug.out("    found dialogue: " .. l.text)
			local res = {}
			do_line(styles, l, config, res)
			substation.debug.out("    lines returned by do_line: " .. #res)
			for j,nl in ipairs(res) do
				subtitles.insert(i+j, nl)
			end
			substation.debug.out("    done inserting generated lines")
			subtitles.delete(i)
			i = i + #res
		else
			substation.debug.out("    not dialogue")
			i = i + 1
		end
		substation.progress.task(string.format("Producing effect (%d/%d)", i, #subtitles))
		substation.progress.set(100 * i / #subtitles)
	end
end

function do_line(styles, line, config, res)
	local k = substation.parse_karaoke_data(line)
	substation.debug.out("        syllables generated from line: " .. #k)
	local left = 0
	for j = 1, #k do
		substation.debug.out("        syllable " .. j .. " is: " .. k[j].text)
		local nl = table.copy(line)
		nl.text = string.format("{\\t(%d,%d,\\fscx50)\\pos(%d,20)}%s", k[j].start_time, k[j].end_time, left, k[j].text_stripped)
		left = left + (substation.text_extents(styles[nl.style], k[j].text_stripped))
		table.insert(res, nl)
	end
end


substation.register_filter("Stupid karaoke", "Makes some more karaoke-like stuff", 2000, test6, nil)
substation.register_filter("Lame test", "Simple test of filters, just inserting a new line", 2000, test6_2)
