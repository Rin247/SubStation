# SubStation Backlog

SubStation v1.0.0 is a fresh-start rename of Aegisub with a new product
name, a new GitHub home, a clean version scheme, and pseudo-portable
user data. The build, the runtime, the file formats, the editor, the
video/audio pipeline, and the Lua automation are all still Aegisub
under the hood.

This document tracks everything we deliberately deferred so that future
work has a clear map. The items below are **not** in any particular order
of priority. Pick whichever is most useful next.

---

## Renderer & windowing

These three items are related: the current renderer is hand-rolled OpenGL
1.x fixed-function on top of `wxGLCanvas` (X11/GLX). Replacing it
matters for wayland-only systems, modern hardware, and HDR support.

### Migrate the video renderer to Vulkan

- **Where**: `src/video_display.cpp`, `src/video_out_gl.cpp`, `src/gl_*`.
  These files implement a hand-rolled OpenGL 1.x pipeline: fixed-function
  calls like `glBegin`/`glVertex2f`/`glPushMatrix`, a custom font cache,
  and a custom GL state machine.
- **Why**: OpenGL 1.x has no Vulkan equivalent. A real Vulkan renderer
  is a from-scratch implementation: pipelines, descriptor sets, command
  buffers, swapchain management, MSAA resolve, texture upload, and
  vertex/index buffer management. Hardware decode (via Vulkan Video)
  and HDR are downstream of this.
- **Effort**: months. This is the largest single item in the backlog.
- **Strategy options**:
  1. Write Vulkan from scratch in `src/video_out_vk.cpp`.
  2. **Recommended first step**: use `libmpv` (a mature, Vulkan-first,
     Wayland-native, X11-falling-back renderer) as the video backend
     and shell out to it from `src/video_box.cpp`. This is a real
     shippable change in one session because the existing code already
     shells out to `ffms2` for video frames.
  3. Use Qt6's `QVulkanWindow` if/when we move to Qt6 (see below).

### Add proper Wayland support, drop X11

- **Where**: `src/video_display.cpp` (the `GetXWindow()` call is the
  giveaway), the wxWidgets event loop, the AUI/docking code, the
  drag-and-drop layer.
- **Why**: Modern Linux distros are increasingly Wayland-only. XWayland
  works but is going away.
- **Effort**: weeks-to-months, mostly gated by the renderer decision
  (Vulkan and Wayland go hand-in-hand via `wl_vulkan`).
- **Strategy**: ship alongside the Vulkan renderer. wxWidgets 3.3 has a
  Wayland backend via GTK 3.22+, so the menus and dialogs can be made
  Wayland-native even before the renderer is. The video display is the
  hard part.

### Drop X11 entirely

- **Where**: build configuration, the `wxGLCanvas` call sites, the
  `xcb` / `Xlib` shims in `libsubstation/unix/`.
- **Why**: see Wayland support. X11 is legacy.
- **Effort**: same as Wayland support — they're really one project.
- **Note**: keep XWayland as a fallback for at least one release cycle
  after Wayland support ships. Some users have screen recorders, X11-only
  accessibility tools, etc.

---

## UI toolkit

### Migrate the UI from wxWidgets to Qt6

- **Where**: every file under `src/`. wxWidgets 3.3 is the current UI
  toolkit. A migration touches:
  - `wxAuiManager` → `QDockWidget`
  - `wxScintilla` (the subtitle editor) → `QPlainTextEdit` with a
    custom syntax highlighter. **This is the big one**: Scintilla has
    years of subtitle-editor-specific tuning that we'd lose. The
    realistic path is a multi-month line-by-line port of the Scintilla
    features we use.
  - `wxGLCanvas` → `QOpenGLWidget` (or `QVulkanWindow` if/when we
    switch renderers)
  - `wxCommandLine` / `wxLocale` / `wxFileConfig` → `QCommandLineParser`
    / `QLocale` / `QSettings`
  - ~150 menu commands, ~80 command IDs, the `agi::cmd::Command` base
    class with `CMD_NAME` / `STR_MENU` / `STR_DISP` / `STR_HELP` macros
  - Custom Lua bindings in `src/auto4_lua.cpp` (~3000 lines) that
    interact with the wxWidgets event loop
- **Why**: Qt6 has better Wayland support out of the box, a saner
  modular structure, better tooling, and a healthier contributor
  community than wxWidgets.
- **Effort**: 6-12 months for a team that knows the codebase.
- **Strategy**:
  1. Port the menu/command system first (highest leverage, lowest
     risk).
  2. Port dialogs and preferences next.
  3. Port the Scintilla-based editor last (highest risk, biggest
     feature loss).
  4. Keep the wxWidgets build working in parallel throughout so we
     can ship the port incrementally.
- **See**: a port plan with file-by-file breakdown belongs in
  `docs/port-to-qt6.md` (not yet written).

---

## Features

### Hearing-impaired / accessibility features (SubtitleEdit parity)

SubtitleEdit has a number of features for cleaning up subtitles for
deaf / hard-of-hearing viewers. We've stubbed menu entries for some of
these; the actual implementations are tracked here.

- **Remove lines for the deaf** — drop subtitles that have no audio
  cue, or are flagged as `[Hearing Impaired]`, or are pure scene
  descriptions. This requires a way to detect "no audio cue" which
  means inspecting the video's audio track for silence around each
  subtitle's time range. Add a menu entry in the Tools menu and a
  Lua API.
- **Fix common errors** — capitalization, punctuation, line breaks,
  common OCR mistakes. This is mostly a regex + dictionary pass.
- **Fix RTL** — for Arabic / Hebrew subtitles, swap the visual order
  in the source so the rendering is correct.
- **Hearing-impaired line classification** — train or hand-write a
  classifier that flags lines as `[Music]`, `[Sound]`, `[Speaker]`,
  etc. Requires the OpenSubtitles or similar dataset.
- **OCR-based transcription** — the biggest one. Use Tesseract or a
  modern model to generate subtitles from the video. Out of scope for
  this backlog entry; needs its own doc.

### Portable build re-enable

- **Where**: `packages/win_installer/portable/`, the deleted
  `fragment_migrate_code.iss` (no, that one is intentionally gone —
  the user no longer wants migration from Aegisub).
- **Why**: We removed the portable build from CI in commit `787e250d1`
  because the `create-portable.ps1` script kept hitting edge cases.
- **Effort**: hours-to-days to debug the script. The script's path
  layout used nested folders, which the user wanted flattened. That's
  done; the script's `meson install` invocation is the part that
  fails.
- **Status**: the meson `win-portable` target and
  `create-portable.ps1` script are still in the tree, so re-enabling is
  a CI matrix change plus a debug session.

### Linux ARM64 build (AppImage + native)

- **Where**: deleted `cross/aarch64-linux-gnu.ini` (this is the
  feature branch's job to re-add), the dropped entry in
  `.github/workflows/appimage.yml`.
- **Why**: We dropped the AppImage arm64 build because it kept failing
  for environment-specific reasons. Restoring it needs:
  1. Restoring the cross file.
  2. Diagnosing the failure: probably the bundled wxWidgets cmake
     subproject doesn't link glib-2.0 / gobject-2.0 / gdk-pixbuf-2.0
     on ARM64 the way it does on x86_64.
  3. Re-enabling the matrix entry.
- **Effort**: half a day, mostly trial-and-error on the runner.

### Windows ARM64 cross-build

- **Where**: deleted `cross/windows-arm64-msvc.ini`, the dropped
  matrix entry in `.github/workflows/ci.yml`.
- **Why**: Same as Linux ARM64. Restoring needs the cross file and
  a CI matrix entry that:
  1. Uses `Enter-VsDevShell -arch=arm64 -host_arch=x64`.
  2. Locates the x86 SDK's `rc.exe` (already done in commit
     `4b2b8d440`).
  3. Locates `llvm-strip.exe` under `$env:VS\VC\Tools\LLVM\bin\`.
  4. Passes `--cross-file=cross/windows-arm64-msvc.ini` to
     `meson setup`.
- **Effort**: half a day.

---

## Internal cleanup

### C++ identifier rename (post-mechanical-rename)

The mechanical rename turned `Aegisub` → `SubStation` everywhere
**except** in C++ identifiers, because `\bAegisub\b` (word-boundary)
doesn't match inside `AegisubApp`, `AegisubLocale`,
`GetAegisubLongVersionString`, etc. The first-pass script had to be
extended with a per-identifier replacement list, and a few slipped
through. The C++ class names still reflect the old product:
`AegisubApp`, `AegisubLocale`, `AegisubFileDropTarget`, and similar.
The rename script's output is **on disk but unverified**: the codebase
has not been compiled end-to-end since the rename. A clean, complete
identifier rename is a follow-up that requires a build to verify.

### User-data migration from Aegisub

- **Decision**: there is no migration. SubStation is a fresh product;
  users who upgrade from Aegisub 3.x start with default config and
  copy their `?user/` files manually if they want.
- **Where**: the `?user` path resolution in
  `libsubstation/unix/path.cpp` (`~/.substation` on Linux) and
  `libsubstation/common/path.cpp` (the token definitions). The
  pseudo-portable mode added in the rename commit looks for a `Data/`
  subdirectory next to the executable; if found, it becomes the user
  data dir. The pseudo-portable mode is the recommended layout for
  new users.
- **Status**: this is by design, not a bug. Document it in the
  user-facing changelog.

### Update checker

- **Decision**: disabled by default. The `enable_update_checker` meson
  option defaults to `false`, and the `app/updates` menu entry, the
  `PerformVersionCheck` calls, and the auto-prompt have been removed.
  No `SubStation` user is being asked to check for updates.
- **Where**: `meson_options.txt`, `src/command/app.cpp`.
- **Status**: this is by design.

### External references cleanup

- All `aegisub.org` URLs in the metainfo, About dialog, and install
  text have been replaced with the new GitHub repo. The LICENCE
  file's copyright line already says "SubStation Project" (the
  Aegisub→SubStation rename touched it inconsistently; the trailing
  `-- END AEGISUB LICENSE --` is now `-- END SUBSTATION LICENSE --`).
- The old `aegisub-team`, `Aegisub IRC channel`, `Aegisub website`,
  and Discord references are gone. Anything that still says "Aegisub"
  in user-visible text is a bug — file an issue.
- Author emails (`nielsm@aegisub.org`, etc.) are preserved as
  historical attribution. The header comments throughout the
  codebase still credit the original authors.

---

## How to use this file

This file lives on `main` so that anyone who clones the repo sees it.
When picking up an item:

1. Create a feature branch: `git checkout -b feat/<item>`.
2. Update this file: change `- [ ]` to `- [WIP]` when starting, and
   to `- [DONE]` (with the merge commit hash) when finished.
3. Move the item to a "Completed" section at the bottom of this file
   so history is preserved.
4. Link the PR that closed the item so future grep can find it.

When proposing a new item: add it under the appropriate section
above. Don't move items between sections without a discussion in a
linked issue.
