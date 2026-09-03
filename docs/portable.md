# Portable Mode

SubStation supports a "portable" install layout: the entire application,
including its configuration, cache, and user data, lives inside a single
folder that can be moved freely between machines (a USB drive, a network
share, a per-project folder, etc.). Nothing is written to system
locations like `~/.config`, `%APPDATA%`, or `~/Library/Application Support`.

## How to enable portable mode

Portable mode is **auto-detected** at startup. There is no flag, no build
option, and no installer switch. Just put a directory called `data/`
next to the SubStation executable (or one level up, for a `bin/` subdir
layout) and launch the app.

The application looks for the directory in this order:

1. `<exe>/data/` — the directory containing the SubStation binary.
2. `<exe>/../data/` — for a layout where the binary is in a `bin/`
   subdirectory (e.g. a manual install on Linux).

If neither directory exists, SubStation uses the normal system locations
(see [Where SubStation writes](#where-substation-writes) below).

### Example layout

**Simple layout** (Windows or a single-folder Linux install):

```
SubStation/
├── SubStation.exe        (Windows)
├── SubStation            (Linux)
├── *.dll                 (Windows: bundled runtime, wxWidgets, etc.)
├── locale/               (compiled translations)
├── automation/           (bundled Lua macros)
└── data/                 <-- portable-mode trigger
    ├── config.json       (optional, seeded by the Windows portable builder)
    ├── dictionaries/     (Hunspell spell-check dictionaries)
    ├── log/              (created at first run)
    ├── catalog/          (subtitle style catalogs)
    ├── hotkey.json
    ├── menu.json
    ├── mru.json
    ├── recovered/        (auto-save recovery)
    ├── shift_history.json
    └── ffms2cache/       (FFmpeg source index cache)
```

**`bin/` subdir layout** (Debian-style manual installs):

```
SubStation/
├── bin/
│   └── substation        (executable)
├── share/
│   ├── locale/
│   └── substation/automation/
└── data/                 <-- portable-mode trigger
    └── ...
```

## What is stored where in portable mode

When a `data/` directory is detected, all four path tokens point inside
it:

| Token | Resolves to (portable) | Resolves to (system install) |
| --- | --- | --- |
| `?user` | `<data>/` | `~/.substation/` (Linux), `%APPDATA%/SubStation/` (Windows), `~/Library/Application Support/SubStation/` (macOS) |
| `?local` | `<data>/` | same as `?user` |
| `?data` | `<data>/` | the install prefix (`/usr/local/share/substation/`, `C:/Program Files/SubStation/`, `MyApp.app/Contents/SharedSupport/`) |
| `?dictionary` | `<data>/dictionaries/` | `/usr/share/hunspell` (Linux), `<data>/dictionaries/` (Windows/macOS) |

A single `data/` directory holds everything because portable installs
are single-user by definition: there is no concept of per-user config
when the application is meant to be relocatable.

## First-run behavior

The first time a user launches SubStation with a `data/` directory
present, the app creates its own `log/`, `recovered/`, and other
working files inside `data/`. There is **no `config.json` requirement**:
the directory just needs to exist.

On subsequent runs, anything written in the previous session is read
back. This means a portable install behaves like a stateful, single-
instance application: the config, the style catalog, the recent files
list, the spell-check additions, and the FFmpeg index cache all
survive across launches and across machines.

## Building a portable distribution

The Windows portable build is produced by
`packages/win_installer/portable/create-portable.ps1`. It lays out:

- The compiled executable and its bundled DLLs (wxWidgets, MSVC CRT, etc.)
  in the root of the zip.
- A `data/` subfolder with the spell-check dictionaries and a seeded
  `config.json`.
- The compiled translations in `locale/`.
- The bundled automation scripts in `automation/`.

The result is a single zip that unzips into a self-contained
`substation-vX.Y.Z-portable-<arch>/` directory. The user can put this
anywhere — `~/Apps/`, a USB stick, `C:\Tools\` — and run the binary
directly.

For Linux, `tools/create_appimage.sh` produces an AppImage which is
the equivalent portable format. The auto-detect logic recognizes the
`AppDir` layout and routes paths into `AppDir/data/`.

For macOS, the `.app` bundle is normally installed to `/Applications/`
and uses system locations. A "drag-wherever" portable install on macOS
is not currently produced by the build system; users can build one
manually by putting the `.app` in a writable location and creating a
`MyApp.app/Contents/MacOS/data/` directory, but this is untested.

## Disabling auto-detect for debugging

Portable mode is auto-detected; there is no flag to disable it from
within the running app. If you need to test the system-location path
on a machine that happens to have a `data/` folder next to the
executable (a leftover from a portable build, for example), simply
move or rename the `data/` directory and relaunch.
