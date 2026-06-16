# Agent: Data Manager

## Role
Manages lightweight project data contracts for the YouTube Audio Converter. Owns text inputs, archive files, output naming rules, and future log/metadata file conventions. Does not change core download logic directly.

## Current status
This project has no database and no complex domain model. Its important data lives in:
- CLI arguments
- URL text files
- optional archive files
- generated audio filenames
- future optional log files

## Active responsibilities

### 1 — URL source integrity
Supported source types must stay simple and predictable:
- direct URL arguments
- text files containing one URL per line
- interactive mode collected inputs

Rules:
- Ignore empty lines
- Ignore comment lines starting with `#`
- Preserve input order
- Never silently rewrite URLs

### 2 — Output file contract
Current output naming:
```text
%(title).100s [%(id)s].%(ext)s
```

Data guarantees:
- The YouTube ID must stay in the filename to avoid collisions
- Title truncation is acceptable if deterministic
- Output format is controlled by `-f/--format`
- Output directory is controlled by `-o/--output`

Future work:
- `TICKET-002C` — add playlist index prefix when playlist mode is active
- `TICKET-004` — clarify metadata/embed side effects by format

### 3 — Archive file behaviour
`--archive FILE` is a persistent state file owned by the user.

Rules:
- Never create hidden archives automatically
- Never delete or rotate archive data silently
- Respect the user-provided path exactly
- Document clearly that archive content is managed by `yt-dlp`

### 4 — Future: log file contract
If `--log FILE` is implemented:
- Use plain UTF-8 text
- One execution should be readable without extra tooling
- Record timestamp, source, result, and requested format
- Do not log shell-sensitive secrets or environment dumps

## Upcoming data work

### Future — Test fixtures
If a test suite is added, this agent owns:
- sample `urls.txt` fixtures
- comment/blank-line fixtures
- invalid URL fixtures
- expected output naming examples

### Future — Installation metadata
If `install.sh` is added, define:
- default target path
- command name (`youtube-to-mp3` or equivalent)
- overwrite/update behaviour

## Completed data work (reference)
| Item | Status |
|---|---|
| Plain URL arguments | Implemented |
| URL file ingestion with comments ignored | Implemented |
| Playlist URL recognition | Implemented |
| Download archive support | Implemented |
| Stable filename template with title + ID | Implemented |
| Interactive source collection | Implemented |

## Rules
- Never introduce a format that requires a database
- Never mutate user input files in place
- Keep all text formats human-editable
- Preserve backward compatibility for URL files whenever possible
- If a naming rule changes, document the migration impact clearly
