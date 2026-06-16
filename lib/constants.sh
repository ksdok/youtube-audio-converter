#!/bin/bash
# constants.sh — Centralized configuration and patterns for youtube_to_mp3
# Sourced by all other modules.
# shellcheck disable=SC2034

# ── Default configuration ──────────────────────────────────────────────
readonly DEFAULT_OUTPUT_DIR="./mp3"
readonly DEFAULT_AUDIO_FORMAT="mp3"
readonly DEFAULT_AUDIO_QUALITY="0"  # best quality for yt-dlp

# ── Terminal colors ────────────────────────────────────────────────────
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ── Supported URL patterns ─────────────────────────────────────────────
# Each pattern on its own line for readability and maintainability.
readonly YOUTUBE_URL_PATTERNS=(
    'https://www.youtube.com/watch?*'
    'http://www.youtube.com/watch?*'
    'https://youtube.com/watch?*'
    'http://youtube.com/watch?*'
    'https://music.youtube.com/watch?*'
    'http://music.youtube.com/watch?*'
    'https://youtu.be/*'
    'http://youtu.be/*'
    'https://www.youtube.com/shorts/*'
    'http://www.youtube.com/shorts/*'
    'https://youtube.com/shorts/*'
    'http://youtube.com/shorts/*'
    'https://www.youtube.com/live/*'
    'http://www.youtube.com/live/*'
    'https://youtube.com/live/*'
    'http://youtube.com/live/*'
)

readonly YOUTUBE_PLAYLIST_PATTERNS=(
    'https://www.youtube.com/playlist?*'
    'http://www.youtube.com/playlist?*'
    'https://youtube.com/playlist?*'
    'http://youtube.com/playlist?*'
    'https://music.youtube.com/playlist?*'
    'http://music.youtube.com/playlist?*'
)

# ── Output filename template ───────────────────────────────────────────
# yt-dlp output template: truncated title + video ID
readonly OUTPUT_TEMPLATE='%(title).100s [%(id)s].%(ext)s'

# ── Exit codes ─────────────────────────────────────────────────────────
readonly EXIT_OK=0
readonly EXIT_MISSING_DEP=1
readonly EXIT_INVALID_ARG=2
readonly EXIT_NO_URLS=3
readonly EXIT_PARTIAL_FAIL=4
readonly EXIT_INTERRUPTED=130