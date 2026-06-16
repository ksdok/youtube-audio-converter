#!/bin/bash
# cli.sh — Command-line argument parsing
# Produces clean configuration variables for the rest of the program.
# shellcheck disable=SC2034

# ── Help ───────────────────────────────────────────────────────────────

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [URLS...|FILE]

Extract audio from YouTube videos and convert to audio files.

Options:
  -h, --help           Display this help
  -o, --output DIR     Output directory (default: ${DEFAULT_OUTPUT_DIR})
  -f, --format FORMAT  Output audio format (default: ${DEFAULT_AUDIO_FORMAT})
      --playlist       Process YouTube playlists entirely
      --archive FILE   Use yt-dlp download archive to skip duplicates
  -i, --interactive    Start the interactive assistant
      --dry-run        Show what would be downloaded, without downloading

Examples:
  $(basename "$0") https://www.youtube.com/watch?v=example1
  $(basename "$0") urls.txt
  $(basename "$0") -o /path/to/music urls.txt
  $(basename "$0") --playlist https://www.youtube.com/playlist?list=...
  $(basename "$0") --archive downloaded.txt urls.txt
  $(basename "$0") --dry-run https://www.youtube.com/watch?v=example1
EOF
}

# ── Argument parser ────────────────────────────────────────────────────
# Sets global config variables (with defaults from constants.sh).
# Remaining positional args (URLs/files) are left in CONFIG_ARGS.

parse_args() {
    # Reset to defaults
    CONFIG_OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    CONFIG_FORMAT="$DEFAULT_AUDIO_FORMAT"
    CONFIG_PLAYLIST_MODE=false
    CONFIG_ARCHIVE_FILE=""
    CONFIG_INTERACTIVE=false
    CONFIG_DRY_RUN=false
    CONFIG_ARGS=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit "$EXIT_OK"
                ;;
            -o|--output)
                [ $# -lt 2 ] && { log_error "Option $1 requires a directory."; exit "$EXIT_INVALID_ARG"; }
                CONFIG_OUTPUT_DIR="$2"
                shift 2
                ;;
            -f|--format)
                [ $# -lt 2 ] && { log_error "Option $1 requires a format."; exit "$EXIT_INVALID_ARG"; }
                CONFIG_FORMAT="$2"
                shift 2
                ;;
            --playlist)
                CONFIG_PLAYLIST_MODE=true
                shift
                ;;
            --archive)
                [ $# -lt 2 ] && { log_error "Option $1 requires a file path."; exit "$EXIT_INVALID_ARG"; }
                CONFIG_ARCHIVE_FILE="$2"
                shift 2
                ;;
            -i|--interactive)
                CONFIG_INTERACTIVE=true
                shift
                ;;
            --dry-run)
                CONFIG_DRY_RUN=true
                shift
                ;;
            --)
                shift
                CONFIG_ARGS+=("$@")
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help >&2
                exit "$EXIT_INVALID_ARG"
                ;;
            *)
                CONFIG_ARGS+=("$1")
                shift
                ;;
        esac
    done
}
