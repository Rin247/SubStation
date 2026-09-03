; This file declares all installables related to SubStation Automation

[Files]
DestDir: {app}\automation\autoload; Source: {#SOURCE_ROOT}\automation\autoload\cleantags-autoload.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: macros\bundled
DestDir: {app}\automation\autoload; Source: {#SOURCE_ROOT}\automation\autoload\karaoke-auto-leadin.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: macros\bundled
DestDir: {app}\automation\autoload; Source: {#SOURCE_ROOT}\automation\autoload\kara-templater.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: macros\bundled
DestDir: {app}\automation\autoload; Source: {#SOURCE_ROOT}\automation\autoload\select-overlaps.moon; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: macros\bundled
DestDir: {app}\automation\autoload; Source: {#SOURCE_ROOT}\automation\autoload\strip-tags.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: macros\bundled

DestDir: {app}\automation\demos; Source: {#SOURCE_ROOT}\automation\demos\future-windy-blur.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: macros\demos
DestDir: {app}\automation\demos; Source: {#SOURCE_ROOT}\automation\demos\raytracer.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: macros\demos

DestDir: {app}\automation\include\substation\internal; Source: {#SOURCE_ROOT}\automation\include\substation\internal\argcheck.moon; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include\substation\internal; Source: {#SOURCE_ROOT}\automation\include\substation\internal\ffi.moon; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main

DestDir: {app}\automation\include\substation; Source: {#SOURCE_ROOT}\automation\include\substation\clipboard.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include\substation; Source: {#SOURCE_ROOT}\automation\include\substation\lfs.moon; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include\substation; Source: {#SOURCE_ROOT}\automation\include\substation\re.moon; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include\substation; Source: {#SOURCE_ROOT}\automation\include\substation\unicode.moon; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include\substation; Source: {#SOURCE_ROOT}\automation\include\substation\util.moon; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main

DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\cleantags.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\clipboard.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\karaskel.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\karaskel-auto4.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\lfs.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\moonscript.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\re.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\unicode.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\unicode-monkeypatch.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\utils.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main
DestDir: {app}\automation\include; Source: {#SOURCE_ROOT}\automation\include\utils-auto4.lua; Flags: ignoreversion overwritereadonly uninsremovereadonly; Attribs: readonly; Components: main

#ifdef DEPCTRL
DestDir: {userappdata}\SubStation\automation; Source: {#DEPS_DIR}\DependencyControl\automation\*; Flags: ignoreversion recursesubdirs createallsubdirs; Components: macros\modules\depctrl
#endif

[InstallDelete]
Type: files; Name: "{userappdata}\SubStation\l0.UpdateFeed_*.json"
Type: files; Name: "{userappdata}\SubStation\DependencyControl.json"     
Type: files; Name: "{userappdata}\SubStation\Nudge.json"
Type: files; Name: "{userappdata}\SubStation\PasteAILines.json"
Type: files; Name: "{userappdata}\SubStation\ASSWipe.json"
Type: files; Name: "{userappdata}\SubStation\automation\include\DM\DownloadManager.dll"
Type: files; Name: "{userappdata}\SubStation\automation\include\BM\BadMutex.dll"
Type: files; Name: "{userappdata}\SubStation\automation\include\PT\PreciseTimer.dll"

#ifdef CLEANUP_UNBUNDLED_MODULES
; Remove the module copies earlier versions bundled, so the DependencyControl-managed ones take
; over. Lua resolves these paths before DependencyControl's own module search, so left in place
; they keep shadowing the managed copies and never migrate.
;
; Opt-in, because it also removes them from scripts that use these modules directly without
; DependencyControl and thus cannot reach the replacements.
Type: files; Name: "{userappdata}\SubStation\automation\include\Yutils.lua"
Type: files; Name: "{userappdata}\SubStation\automation\include\json.lua"
Type: filesandordirs; Name: "{userappdata}\SubStation\automation\include\json"
Type: filesandordirs; Name: "{userappdata}\SubStation\automation\include\requireffi"
Type: filesandordirs; Name: "{userappdata}\SubStation\automation\include\BM"
Type: filesandordirs; Name: "{userappdata}\SubStation\automation\include\PT"
Type: filesandordirs; Name: "{userappdata}\SubStation\automation\include\DM"
#endif
