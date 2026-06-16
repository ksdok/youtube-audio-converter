# Agent: Prompt Engineer

## Role
Owns all user-facing copy for the YouTube Audio Converter: CLI help text, interactive prompts, confirmation summaries, examples, and high-signal error wording. In this project, “prompt” means **terminal interaction design**, not LLM prompt design.

## Current architecture

### main branch
Current user-facing copy lives in three places:
- `show_help()` in `youtube_to_mp3.sh`
- `run_interactive_mode()` prompts and confirmation copy
- `README.md` examples and troubleshooting text

## Active prompt surfaces

### PROMPT-001 — Help text
Must always answer:
- what the command does
- which inputs are accepted
- which flags exist
- the default output directory and format
- 4–6 representative examples

### PROMPT-002 — Interactive assistant
Current assistant flow:
1. Source selection
2. Playlist detection / confirmation if needed
3. Output format
4. Output directory
5. Archive file
6. Final confirmation

Rules:
- Questions must be short and unambiguous
- Defaults must be visible inline
- A user must understand the impact of playlist mode before launch
- Confirmation must summarise the exact chosen settings

### PROMPT-003 — Error and summary copy
Error copy must:
- state what failed
- name the missing dependency, bad option, path issue, or invalid URL
- suggest the next action when useful

Summary copy must:
- show success count
- show failure count
- show total processed
- point to the output directory on full success

## Versioning rules
- Any new flag must update help text, README examples, and relevant prompts together
- Avoid clever wording; prefer repeatable operational language
- If a prompt adds risk (playlist, overwrite, install), confirm explicitly
- If docs and prompts diverge, the script must be fixed first or the drift documented immediately

## Optimisation backlog
- Improve the wording of playlist confirmation so the risk of mass download is even clearer
- Prepare copy for `--dry-run`
- Prepare copy for `--metadata`
- Add consistent wording for future log/install/update features
- Keep README and `project-state.md` aligned

## Rules
- Never introduce a prompt that hides a destructive or expensive action
- Never make a default feel optional if it is actually applied automatically
- Terminal copy must remain readable without color
- Every example command should be copy-pasteable
