script_name = "Test furigana"
script_description = "Tests the Auto4/Lua karaskel furigana and multi-highlight code"
script_author = "jfs"

include "karaskel.lua"

function dump_furi(subs)
	substation.progress.task("Collecting header data")
	local meta, styles = karaskel.collect_head(subs, true) -- make sure to create furigana styles
	
	substation.progress.task("Processing lines")
	for i = 1, #subs do
		local l = subs[i]
		if l.class == "dialogue" then
			substation.progress.task(l.text)
			karaskel.preproc_line_text(meta, styles, l)
			
			-- Dump the thing
			substation.debug.out(4, "Line: %s\nStripped: %s\nDuration: %d\n", l.text, l.text_stripped, l.duration)
			substation.debug.out(4, "Karaoke syllables: (%d)\n", l.kara.n)
			for s = 0, l.kara.n do
				local syl = l.kara[s]
				substation.debug.out(4, "\tSyllable: text='%s' stripped='%s' duration=%d, start/end_time=%d/%d, inline_fx='%s', highlights=%d\n", syl.text, syl.text_stripped, syl.duration, syl.start_time, syl.end_time, syl.inline_fx, syl.highlights.n)
				substation.debug.out(4, "\t\tHighlights:")
				for h = 1, syl.highlights.n do
					local hl = syl.highlights[h]
					substation.debug.out(4, " %d-%d=%d", hl.start_time, hl.end_time, hl.duration)
				end
				substation.debug.out(4, "\n")
			end
			substation.debug.out(4, "Furigana parts: (%d)\n", l.furi.n)
			for f = 1, l.furi.n do
				local furi = l.furi[f]
				substation.debug.out(4, "\tFurigana: text='%s', duration=%d, start/end_time=%d/%d, flags=%s%s, syl='%s'\n", furi.text, furi.duration, furi.start_time, furi.end_time, furi.isbreak and "b" or "", furi.spillback and "s" or "", furi.syl.text_stripped)
			end
			substation.debug.out(4, "  - - - - - -\n")
		end
	end
	substation.debug.out(4, "Done dumping!")
end

function layout_furi(subs)
	substation.progress.task("Collecting header data")
	local meta, styles = karaskel.collect_head(subs, true) -- make sure to create furigana styles
	
	substation.progress.task("Processing lines")
	for i = 1, #subs do
		local l = subs[i]
		if l.class == "dialogue" then
			substation.progress.task(l.text)
			karaskel.preproc_line_pos(meta, styles, l)
			substation.progress.task("Line layouting done, rendering...")
			substation.debug.out(4, "line width: %.2f\n", l.width)
			-- First all syllables
			for s = 0, l.kara.n do
				local syl = l.kara[s]
				local lc = table.copy(l)
				lc.text = string.format("{\\pos(%.1f,%.1f)\\k%d\\k%d\\an5}%s", l.left+syl.center, l.middle, syl.start_time/10, syl.kdur, syl.text_stripped)
				subs.append(lc)
			end
			-- Then all furigana
			for f = 1, l.furi.n do
				local furi = l.furi[f]
				local lc = table.copy(l)
				lc.text = string.format("{\\pos(%.1f,%.1f)\\k%d\\k%d\\an5}%s", l.left+furi.center, l.top-l.height/2, furi.start_time/10, furi.duration/10, furi.text)
				lc.style = furi.style.name
				subs.append(lc)
			end
		end
	end
	substation.set_undo_point("Furigana layout test")
end

substation.register_macro("Test furi parsing", "Run the furigana parsing code and dump the result", dump_furi)
substation.register_macro("Test furi layout", "Run the furigana layout code and render the result", layout_furi)
