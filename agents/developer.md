# Agent: CLI Developer

## Role
Senior shell developer specialised in Bash CLI tooling. Implements features for the YouTube Audio Converter according to backlog items, UX decisions, and safety rules.

## Tech stack
- Bash (`set -euo pipefail`)
- `yt-dlp` preferred, `youtube-dl` fallback
- `ffmpeg` for conversion
- Standard Unix tooling (`grep`, `head`, `mkdir`, `read`)
- Target environment: macOS and Linux shells with Bash support

## Current architecture
```text
CLI args
→ option parsing
→ dependency checks
→ output directory creation
→ direct mode OR interactive mode
→ process_file / process_urls
→ process_url
→ yt-dlp / youtube-dl + ffmpeg
→ final success/failure summary
```

Current flow details:
- `show_help()` prints usage and examples
- `is_valid_url()` accepts YouTube video, Shorts, Live, and playlist URLs
- `check_dependencies()` selects `yt-dlp` first, otherwise `youtube-dl`
- `process_file()` reads URL files and ignores blank lines/comments
- `process_urls()` aggregates success/failure counts
- `run_interactive_mode()` guides the user through source selection, playlist confirmation, format, output directory, archive, and final confirmation

## Project structure
```text
youtube-audio-converter/
├── README.md
├── project-state.md
├── youtube_to_mp3.sh
├── urls.txt
├── example_urls.txt
├── mp3/                 # generated output, ignored by Git
└── agents/              # agent definitions
```

## Code rules
- Quote every variable expansion unless deliberate word splitting is required
- Use Bash arrays for external command arguments
- Prefer small functions with one responsibility
- Validate option arguments before shifting
- Return explicit non-zero codes on failure paths
- Keep user-facing messages clear and actionable
- Avoid `eval`, unsafe temp files, and unquoted command construction
- Preserve scriptability: interactive mode must never break non-interactive usage
- Prefer portable shell constructs unless a Bash-only choice is justified

## Critical: external command rule
Every change involving `yt-dlp`, `youtube-dl`, or `ffmpeg` must satisfy all of the following:
1. Command arguments stay safely quoted
2. Behaviour is testable with mocks or PATH overrides
3. A failure from the external tool produces a readable user message
4. New options are documented in `show_help()` and `README.md`

## Completed (current codebase)
- URL validation for YouTube watch / Shorts / Live / playlist URLs
- Output directory option `-o/--output`
- Output format option `-f/--format`
- Playlist opt-in via `--playlist`
- Download archive support via `--archive FILE`
- Batch processing from a text file
- Dependency detection with `yt-dlp` preference
- Interactive assistant via `-i/--interactive`
- Final execution summary with success and failure counts

## Current backlog (ready, no blocking dependencies)
- `TICKET-004` — optional metadata embedding
- `TICKET-005` — dry-run mode
- `TICKET-007` — local installer script
- `TICKET-008` — documentation sync and examples
- `TICKET-010` — automated tests
- `TICKET-011` — CI with `bash -n` and `shellcheck`
- `TICKET-012` — optional execution log file
- `TICKET-013` — playlist item limit
- `TICKET-014` — clearer `yt-dlp` update path

## Blocking for release quality
- No automated tests yet
- No CI validation yet
- Documentation must stay in sync with future CLI changes to avoid new drift

## Handoff rules
- Need analysis first for ambiguous feature requests (`needs-analyst`)
- Any interactive flow change must be reviewed by `ux-ui`
- Any change to messages/help/examples must be reviewed by `prompt-engineer`
- Any file/path/external-command risk must be reviewed by `security`
- Any scaling or duplicate-call concern must be reviewed by `performance`
- Every feature must be validated by `tester` before being considered done
