# SubStation Roadmap Branch

This branch is a **stub**. It exists on the repo so the long-term
direction has a tracked home, but it does not contain any working
port. Anyone who checks out this branch should expect it not to
build.

The real implementation work for the items below is significant
(months of effort) and is intentionally not started in this session.
The corresponding tracking doc on `main` is `BACKLOG.md`; this
file is a focused tour of the bigger items so a future contributor
can pick one up without re-deriving the plan.

---

## Status

| Item | Status | Effort | Notes |
| --- | --- | --- | --- |
| Drop X11 | not started | weeks | Goes with Wayland; mostly a build-config change once the renderer is Wayland-capable. |
| Wayland support | not started | weeks-to-months | Tied to the renderer decision. wxWidgets 3.3 GTK 3.22+ has a Wayland backend, but the video display is hand-rolled on `wxGLCanvas` (X11/GLX). |
| Migrate to Qt6 | not started | 6-12 months | Largest single item. Touches ~150 files. See "Qt6 port plan" below. |
| Migrate renderer to Vulkan | not started | months | OpenGL 1.x fixed-function has no Vulkan equivalent; this is a from-scratch pipeline. |
| Adopt `libmpv` as the video backend (interim) | not started | days | Realistic first step. `libmpv` is mature, Vulkan-first, Wayland-native. Aegisub already shells out to `ffms2` for video frames. |

None of the above are on this branch. The branch only exists so a
contributor has a place to commit them when work starts.

---

## Renderer & windowing

### Vulkan renderer

- **Where**: `src/video_display.cpp`, `src/video_out_gl.cpp`, `src/gl_*`.
  These files implement a hand-rolled OpenGL 1.x pipeline: fixed-function
  calls like `glBegin`/`glVertex2f`/`glPushMatrix`, a custom font cache,
  and a custom GL state machine.
- **Why**: OpenGL 1.x has no Vulkan equivalent. A real Vulkan renderer
  is a from-scratch implementation: pipelines, descriptor sets, command
  buffers, swapchain management, MSAA resolve, texture upload, and
  vertex/index buffer management. Hardware decode (via Vulkan Video)
  and HDR are downstream of this.
- **Effort**: months.
- **Strategy options**:
  1. Write Vulkan from scratch in `src/video_out_vk.cpp`.
  2. **Recommended first step**: use `libmpv` (a mature, Vulkan-first,
     Wayland-native, X11-falling-back renderer) as the video backend
     and shell out to it from `src/video_box.cpp`. This is a real
     shippable change in one session because the existing code already
     shells out to `ffms2` for video frames.
  3. Use Qt6's `QVulkanWindow` if/when we move to Qt6 (see below).

### Wayland support, drop X11

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
  hard part. Keep XWayland as a fallback for at least one release
  cycle after Wayland support ships.

---

## UI toolkit: Qt6

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

---

## How to use this branch

This branch is a stub. To start work on an item:

1. Create a sub-branch off `main`: `git checkout -b feat/<item> main`.
2. Land the work there.
3. When the work is done, merge to `main` and remove the corresponding
   entry from `BACKLOG.md` on `main`.

To track progress against the items above, update the "Status" table
at the top of this file.
