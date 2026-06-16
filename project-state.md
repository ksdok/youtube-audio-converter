# Project State — YouTube Audio Converter

Last updated: 2026-06-16

## Current status

This project provides a Bash script, `youtube_to_mp3.sh`, that extracts audio from YouTube videos using `yt-dlp` (preferred) or `youtube-dl` (fallback), then converts the result with `ffmpeg`.

### Implemented features
- Convert one or more YouTube URLs to audio files
- Read URLs from a text file
- Ignore blank lines and `#` comments in URL files
- Configure the output format with `-f, --format`
- Configure the output directory with `-o, --output`
- Validate dependencies (`yt-dlp`/`youtube-dl` and `ffmpeg`)
- Show a final success/failure summary
- Support YouTube playlists with explicit `--playlist` opt-in
- Avoid duplicate downloads with `--archive FILE`
- Provide an interactive assistant with `-i, --interactive`
- Keep generated audio out of Git via `.gitignore`

### Current limitations
- No dry-run mode yet
- No metadata/embed option yet
- No automated test suite yet
- No CI workflow yet
- No optional log file yet
- No installer script yet
- No playlist item limit yet

## Repository notes

### Main files
- `youtube_to_mp3.sh` — main script and source of truth for implemented behaviour
- `README.md` — user documentation
- `project-state.md` — project tracking and backlog
- `agents/` — project-specific agent definitions adapted for this repository

### Important note
When documentation and code disagree, `youtube_to_mp3.sh` is the source of truth. For example, the interactive mode is already implemented in the script.

## Complexity scale
- **XS** — trivial change, very low risk
- **S** — small localized improvement
- **M** — medium feature with a few edge cases
- **L** — larger feature affecting multiple parts of the workflow
- **XL** — too large for a single ticket, should be split

## Completed tickets

### TICKET-001 — Rename the main documentation to `README.md`
**Complexity:** XS  
**Status:** Done

Result:
- `README.md` exists at the repository root
- The main documentation is displayed correctly by GitHub

---

### TICKET-002 — Add explicit YouTube playlist support
**Complexity:** L  
**Status:** Partially done

Completed:
- **TICKET-002A** — Playlist URLs are recognized
- **TICKET-002B** — `--playlist` enables full playlist processing

Still open:
- **TICKET-002C** — Add playlist index prefixes to output filenames

---

### TICKET-003 — Add a duplicate-prevention archive
**Complexity:** M  
**Status:** Done

Result:
- `--archive FILE` passes a download archive to `yt-dlp`
- Re-running the same batch or playlist can skip previously processed items

---

### TICKET-006 — Add an interactive mode
**Complexity:** L  
**Status:** Done

Completed:
- **TICKET-006A** — `-i, --interactive` starts the assistant
- **TICKET-006B** — The assistant collects source, format, output directory, and archive settings
- **TICKET-006C** — A final confirmation step is shown before processing starts

---

### TICKET-008 — Improve the README with complete examples
**Complexity:** S  
**Status:** Done

Result:
- The README includes examples for single URLs, multiple URLs, URL files, playlists, custom output folders, and archives
- Troubleshooting and prerequisites are documented

---

### TICKET-009 — Add an open-source license
**Complexity:** XS  
**Status:** Done

Result:
- `LICENSE` exists
- The repository is clearly distributed under the MIT License

## Active backlog

### TICKET-002C — Add playlist index prefixes to filenames
**Complexity:** S  
**Status:** Planned

Description:
When playlist mode is enabled, use an output template that includes the playlist index.

Acceptance criteria:
- Playlist items are saved with an index prefix such as `01 - Title [id].mp3`
- Single-video downloads keep the current naming format

---

### TICKET-004 — Add a metadata/embed option
**Complexity:** M  
**Status:** Planned

Description:
Add a `--metadata` option that forwards metadata-related flags to `yt-dlp` when supported.

Candidate flags:
```bash
--embed-metadata
--embed-thumbnail
```

Acceptance criteria:
- `./youtube_to_mp3.sh --metadata URL` embeds metadata when possible
- Without `--metadata`, behaviour stays unchanged
- The documentation explains format and `ffmpeg` limitations clearly

---

### TICKET-005 — Add a dry-run mode
**Complexity:** M  
**Status:** Planned

Description:
Add a `--dry-run` option to preview what would be processed without creating audio files.

Acceptance criteria:
- `./youtube_to_mp3.sh --dry-run URL` shows the detected title or titles
- No audio file is created
- Works with URL files
- Works with playlists when combined with `--playlist`

---

### TICKET-007 — Add a local installation script
**Complexity:** M  
**Status:** Planned

Description:
Create an `install.sh` script to install the command in a user-executable directory such as `~/.local/bin/youtube-to-mp3`.

Acceptance criteria:
- `./install.sh` copies the script to a user-facing executable path
- The installer checks whether the target directory is in `PATH`, or prints clear instructions
- After installation, the user can run:

```bash
youtube-to-mp3 urls.txt
```

---

### TICKET-010 — Add basic automated tests
**Complexity:** L  
**Status:** Planned

Recommended split:
- **TICKET-010A** — Create a shell test structure
- **TICKET-010B** — Test help output and CLI errors
- **TICKET-010C** — Test URL validation

Acceptance criteria:
- A minimal test command can be run locally
- The test command is documented
- Help, missing arguments, unknown options, and URL validation are covered

---

### TICKET-011 — Add a GitHub Actions validation workflow
**Complexity:** M  
**Status:** Planned

Description:
Add a CI workflow to run syntax checks and ShellCheck on pushes and pull requests.

Acceptance criteria:
- `.github/workflows/ci.yml` exists
- The workflow runs `bash -n youtube_to_mp3.sh`
- The workflow runs `shellcheck youtube_to_mp3.sh`
- The CI badge can be added to the README later if desired

---

### TICKET-012 — Add an optional log file
**Complexity:** M  
**Status:** Planned

Description:
Add a `--log FILE` option to write an execution log.

Acceptance criteria:
- The log includes date/time, URL, status, and requested format
- Successes and failures are visible after execution
- Without `--log`, behaviour stays unchanged

---

### TICKET-013 — Add a playlist item limit
**Complexity:** S  
**Status:** Planned

Description:
Add an option that forwards `--playlist-items` to `yt-dlp`.

Example:
```bash
./youtube_to_mp3.sh --playlist --playlist-items 1-10 "URL_PLAYLIST"
```

Acceptance criteria:
- The option is available mainly for playlist mode
- The value is forwarded correctly to `yt-dlp`
- The help text documents the option

---

### TICKET-014 — Add a clearer `yt-dlp` update path
**Complexity:** S  
**Status:** Planned

Description:
Add a `--update-ytdlp` option or document the recommended update path more clearly, since YouTube changes often and `yt-dlp` must stay current.

Acceptance criteria:
- Users have a clear way to update `yt-dlp`
- The script does not assume `yt-dlp` was installed via `pip`
- The documentation explains both macOS and Linux update paths

## Recommended implementation order
1. TICKET-010 — Automated tests
2. TICKET-011 — CI validation
3. TICKET-005 — Dry-run mode
4. TICKET-004 — Metadata embedding
5. TICKET-007 — Local installer
6. TICKET-012 — Optional log file
7. TICKET-013 — Playlist item limit
8. TICKET-002C — Playlist filename indexing
9. TICKET-014 — Clear `yt-dlp` update workflow

## Release direction
The next useful project milestone should focus on reliability and maintainability rather than feature breadth:
- automated tests
- CI validation
- dry-run support
- optional logging
- installation ergonomics

That path improves confidence in the script without making the core workflow unnecessarily complex.
