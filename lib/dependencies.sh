#!/bin/bash
# dependencies.sh — Check and resolve external dependencies (yt-dlp, ffmpeg)

# ── Dependency checker ─────────────────────────────────────────────────
# Sets YOUTUBE_DL to the resolved downloader command.
# Exits with EXIT_MISSING_DEP if a required tool is missing.

check_dependencies() {
    log_info "Checking dependencies..."

    # --- yt-dlp or youtube-dl ---
    if command -v yt-dlp &>/dev/null; then
        YOUTUBE_DL="yt-dlp"
    elif command -v youtube-dl &>/dev/null; then
        YOUTUBE_DL="youtube-dl"
    else
        log_error "Neither yt-dlp nor youtube-dl is installed."
        cat >&2 <<EOF
yt-dlp installation:
  macOS:    brew install yt-dlp
  Debian:   sudo apt install yt-dlp
  Fedora:   sudo dnf install yt-dlp
  Pip:      pip install yt-dlp
EOF
        exit "$EXIT_MISSING_DEP"
    fi

    # --- ffmpeg ---
    if ! command -v ffmpeg &>/dev/null; then
        log_error "ffmpeg is not installed."
        cat >&2 <<EOF
ffmpeg installation:
  macOS:    brew install ffmpeg
  Debian:   sudo apt install ffmpeg
  Fedora:   sudo dnf install ffmpeg
EOF
        exit "$EXIT_MISSING_DEP"
    fi

    log_success "Dependencies OK — using: $YOUTUBE_DL"
}
