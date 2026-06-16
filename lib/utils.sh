#!/bin/bash
# utils.sh — Logging, prompts, and URL validation utilities

# ── Logging ─────────────────────────────────────────────────────────────
# All output goes through these functions so we can change behavior in one place.
# Usage: log_info "Message", log_success "Done", log_error "Failed", log_warn "Careful"

log_info() {
    printf '%b%b%b\n' "$BLUE" "$*" "$NC"
}

log_success() {
    printf '%b✓ %b%b\n' "$GREEN" "$*" "$NC"
}

log_error() {
    printf '%b✗ %b%b\n' "$RED" "$*" "$NC" >&2
}

log_warn() {
    printf '%b⚠ %b%b\n' "$YELLOW" "$*" "$NC" >&2
}

log_header() {
    printf '%b%b%s%b\n' "$BLUE" "$BOLD" "$*" "$NC"
}

log_step() {
    printf '%b%s%b\n' "$YELLOW" "$*" "$NC"
}

# ── URL validation ─────────────────────────────────────────────────────

# Check if a URL matches any of the given glob patterns.
# Args: $1=URL, $2...=patterns (or use patterns array)
# Returns: 0 if match, 1 if no match
_match_patterns() {
    local url="$1"
    shift
    local pattern
    for pattern in "$@"; do
        # shellcheck disable=SC2254
        case "$url" in
            $pattern) return 0 ;;
        esac
    done
    return 1
}

# Validate a URL as a supported YouTube video URL.
# Includes playlist URLs (they are also valid video URLs).
is_valid_url() {
    local url="$1"
    _match_patterns "$url" "${YOUTUBE_URL_PATTERNS[@]}" \
                 "${YOUTUBE_PLAYLIST_PATTERNS[@]}"
}

# Validate a URL as a YouTube playlist URL specifically.
is_playlist_url() {
    local url="$1"
    _match_patterns "$url" "${YOUTUBE_PLAYLIST_PATTERNS[@]}"
}

# ── Interactive prompts ────────────────────────────────────────────────

# Ask the user a question with an optional default value.
# Prints the user's response (or the default) to stdout.
prompt_user() {
    local question="$1"
    local default="${2:-}"
    local response

    if [ -n "$default" ]; then
        printf '%b%s [%s]:%b ' "$BLUE" "$question" "$default" "$NC"
    else
        printf '%b%s:%b ' "$BLUE" "$question" "$NC"
    fi

    read -r response
    printf '%s\n' "${response:-$default}"
}

# Ask a yes/no question. Returns 0 for yes, 1 for no.
prompt_yes_no() {
    local question="$1"
    local default="${2:-y}"
    local answer

    answer=$(prompt_user "$question" "$default")
    [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

# ── File validation ────────────────────────────────────────────────────

# Check that a file exists and is readable. Returns 0 if OK, 1 otherwise.
require_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi
    if [ ! -r "$file" ]; then
        log_error "File not readable: $file"
        return 1
    fi
    return 0
}

# ── Output directory ───────────────────────────────────────────────────

ensure_output_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        log_info "Creating output directory: $dir"
        mkdir -p -- "$dir"
    fi
}
