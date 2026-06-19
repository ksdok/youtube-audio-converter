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
- Preview downloads without creating files via `--dry-run`
- Keep generated audio out of Git via `.gitignore`
- Keep CLI help and early error output free of decorative banner noise
- Show playlist state in dry-run summaries and clearer `[index/total]` batch progress output
- Make interactive prompts clearer with unnumbered steps and explicit default-value hints

### Current limitations
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
When documentation and code disagree, `youtube_to_mp3.sh` is the source of truth. Keep the documentation in sync with the script.

## Complexity scale
- **XS** — trivial change, very low risk
- **S** — small localized improvement
- **M** — medium feature with a few edge cases
- **L** — larger feature affecting multiple parts of the workflow
- **XL** — too large for a single ticket, should be split

## Completed tickets

### TICKET-001 — Rename the main documentation to `README.md`
**Complexity:** XS  
**Status:** Done (`1003a41`)

Description:
Rename `README_YOUTUBE_MP3.md` to `README.md` so GitHub displays the documentation automatically on the repository page.

Acceptance criteria:
- `README.md` exists at the repository root
- `README_YOUTUBE_MP3.md` is no longer needed
- GitHub displays the documentation correctly

---

### TICKET-002 — Add explicit YouTube playlist support
**Complexity:** L  
**Status:** Partially done

Description:
Allow the script to process a full YouTube playlist without breaking the safer default behaviour that limits normal video URLs to a single video via `--no-playlist`.

#### TICKET-002A — Detect playlist URLs
**Complexity:** S  
**Status:** Done (`1003a41`)

Acceptance criteria:
- `https://www.youtube.com/playlist?list=...` is recognized as supported
- `https://music.youtube.com/playlist?list=...` is recognized as supported
- Non-YouTube URLs are still rejected

#### TICKET-002B — Add a `--playlist` option
**Complexity:** M  
**Status:** Done (`86fb7cb`)

Acceptance criteria:
- `./youtube_to_mp3.sh --playlist "URL_PLAYLIST"` downloads the playlist
- `./youtube_to_mp3.sh "URL_VIDEO_WITH_LIST"` still downloads only one video by default
- `--help` documents the option

#### TICKET-002C — Add playlist index prefixes to filenames
**Complexity:** S  
**Status:** Planned

This remaining sub-ticket is tracked in the Active backlog below.

---

### TICKET-003 — Add a duplicate-prevention archive
**Complexity:** M  
**Status:** Done (`86fb7cb`)

Description:
Add an option that forwards `--download-archive` to `yt-dlp` so already processed videos are not downloaded again.

Acceptance criteria:
- The user can provide a custom archive file
- Without the option, behaviour stays unchanged
- A re-run playlist or batch skips items already present in the archive

---

### TICKET-005 — Add a dry-run mode
**Complexity:** M  
**Status:** Done (`facaa7c`, `2914e6e`, `89cca2d` include recent UX polish)

Description:
Add a `--dry-run` option to preview what would be processed without creating audio files.

Acceptance criteria:
- `./youtube_to_mp3.sh --dry-run URL` shows the detected title or titles
- No audio file is created
- Works with URL files
- Works with playlists when combined with `--playlist`

---

### TICKET-006 — Add an interactive mode
**Complexity:** L  
**Status:** Done (`c0e991b`, `765708c` include recent UX polish)

Description:
Allow a non-technical user to run the script without knowing the CLI flags in advance.

#### TICKET-006A — Add `--interactive`
**Complexity:** S  
**Status:** Done (`987fef8`)

Acceptance criteria:
- `./youtube_to_mp3.sh --interactive` starts the assistant
- `--help` documents the option

#### TICKET-006B — Ask for source, format, and output directory
**Complexity:** M  
**Status:** Done (`c7fb7e0`)

Acceptance criteria:
- The user can choose a source type interactively
- The user can accept default values with Enter
- The chosen values are reused by the normal processing flow

#### TICKET-006C — Add a final confirmation before download
**Complexity:** S  
**Status:** Done (`7b8aacc`)

Acceptance criteria:
- The script shows a summary of the selected source, format, output directory, playlist mode, and archive file
- `y` or `yes` starts processing
- Any other answer cancels cleanly

---

### TICKET-008 — Improve the README with complete examples
**Complexity:** S  
**Status:** Done (`be7242d`)

Description:
Expand the documentation with the main usage patterns and the currently supported options.

Acceptance criteria:
- Example for a single video
- Example for multiple videos
- Example with a URL file
- Example with a playlist
- Example with a custom output folder
- Example with a duplicate-prevention archive
- Expanded troubleshooting section

---

### TICKET-009 — Add an open-source license
**Complexity:** XS  
**Status:** Done (`1003a41`)

Description:
Add a `LICENSE` file so repository usage rights are explicit.

Acceptance criteria:
- `LICENSE` exists
- The README mentions the license
- GitHub detects the repository license

## Active backlog

### TICKET-002C — Add playlist index prefixes to filenames
**Complexity:** S  
**Status:** Planned

Description:
When playlist mode is enabled, use an output template that includes the playlist index.

Acceptance criteria:
- Playlist items are named with an order prefix such as `01 - Title [id].mp3`
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

Description:
Add tests to protect the script behaviour, especially around argument parsing and URL validation.

#### TICKET-010A — Create a shell test structure
**Complexity:** M  
**Status:** Planned

Acceptance criteria:
- A `tests/` directory exists
- A minimal local test command can be run successfully
- The test command is documented

#### TICKET-010B — Test help output and CLI errors
**Complexity:** S  
**Status:** Planned

Acceptance criteria:
- `--help` exits successfully
- Missing arguments return an error
- Unknown options return an error

#### TICKET-010C — Test URL validation
**Complexity:** M  
**Status:** Planned

Acceptance criteria:
- YouTube video URLs are accepted
- Shorts URLs are accepted
- Live URLs are accepted
- Playlist URLs are accepted because playlist support is implemented
- Non-YouTube URLs are rejected

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

### TICKET-015 — Audit fixes (logic, safety, consistency)
**Complexity:** M  
**Status:** Done

Fixes identified during the 2026-06-19 maturity audit.

#### BUG 1 — Playlist detection uses substring heuristic (interactive.sh)
**Complexity:** S  
**Status:** Done

`_interactive_check_playlists` matches the literal substring "playlist" instead of using the existing `is_playlist_url()` validator. A video URL containing "playlist" in its ID triggers a false "Playlist detected!" warning.

Acceptance criteria:
- `is_playlist_url()` is used for both single URLs and file contents
- A video URL that happens to contain "playlist" no longer triggers a false alert

---

#### BUG 4 — No audio format validation (cli.sh, interactive.sh)
**Complexity:** S  
**Status:** Done

The `-f / --format` value is forwarded to `yt-dlp` without validation. An invalid format fails late and unclearly.

Acceptance criteria:
- A supported-formats list is defined in `constants.sh`
- Invalid formats are rejected with a clear error before any download starts
- Interactive mode validates the entered format

---

#### BUG 5 — SIGINT not trapped in batch mode (youtube_to_mp3.sh)
**Complexity:** S  
**Status:** Done

A Ctrl+C during a batch download can leave `.part` / `.webm` temp files in the output directory because only interactive mode has a SIGINT trap.

Acceptance criteria:
- A global SIGINT trap is installed in `main()`
- The trap exits cleanly with `EXIT_INTERRUPTED`

---

#### BUG 2 & 3 — Redundant network calls for title extraction (download.sh)
**Complexity:** M  
**Status:** Documented

`process_url` and `_dry_run_url` each call `yt-dlp --get-title` separately from the download call. For large batches this doubles the network cost. Refactoring the download flow to use `--print` or batch metadata extraction is a larger change that touches core logic and is deferred to a dedicated ticket.

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
3. TICKET-004 — Metadata embedding
4. TICKET-007 — Local installer
5. TICKET-012 — Optional log file
6. TICKET-013 — Playlist item limit
7. TICKET-002C — Playlist filename indexing
8. TICKET-014 — Clear `yt-dlp` update workflow

## Release direction
The next useful milestone should focus on reliability and maintainability rather than feature breadth:
- automated tests
- CI validation
- optional logging
- installation ergonomics
- metadata polish

That path improves confidence in the script without making the core workflow unnecessarily complex.
