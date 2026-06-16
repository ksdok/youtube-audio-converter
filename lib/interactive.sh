#!/bin/bash
# interactive.sh — Interactive mode assistant
# Collects source, configuration, and confirmation from the user,
# then delegates to process_file() or process_urls().

# ── Main interactive flow ───────────────────────────────────────────────

run_interactive_mode() {
    trap 'log_warn "Operation interrupted by user."; exit "$EXIT_INTERRUPTED"' SIGINT

    log_header "Starting interactive assistant..."

    # --- Step 1: Source ---
    # INTERACTIVE_SOURCES and INTERACTIVE_SOURCE_FILE are set as globals
    # by _interactive_collect_source sub-functions and read by
    # _interactive_check_playlists and _interactive_confirm_and_run.
    _interactive_collect_source || return 1

    # --- Step 2: Playlist detection ---
    _interactive_check_playlists

    # --- Step 3: Configuration ---
    _interactive_collect_config

    # --- Step 4: Confirmation ---
    _interactive_confirm_and_run
}

# ── Step 1: Source collection ───────────────────────────────────────────
# Uses global arrays: INTERACTIVE_SOURCES and INTERACTIVE_SOURCE_FILE
# (namerefs are avoided due to shellcheck SC2178/SC2034 issues with
# assigning arrays through references in Bash 4.x.)

_interactive_collect_source() {
    log_step "Step 1: Source selection"

    while true; do
        echo "Choose source type:"
        echo "  1) Single URL"
        echo "  2) Multiple URLs (one per line, empty line to finish)"
        echo "  3) URL file"
        echo "  q) Quit"

        local choice
        read -r -p "Choice [1-3/q]: " choice

        case "$choice" in
            1)
                if _interactive_single_url; then
                    break
                fi
                ;;
            2)
                if _interactive_multi_urls; then
                    break
                fi
                ;;
            3)
                if _interactive_file_url; then
                    break
                fi
                ;;
            q)
                log_warn "Exiting assistant."
                exit "$EXIT_OK"
                ;;
            *)
                log_error "Invalid choice."
                ;;
        esac
    done
}

_interactive_single_url() {
    local url

    while true; do
        url=$(prompt_user "Enter YouTube URL" "")
        if [ -z "$url" ]; then
            log_error "URL cannot be empty."
            continue
        fi
        if is_valid_url "$url"; then
            INTERACTIVE_SOURCES=("$url")
            INTERACTIVE_SOURCE_FILE=""
            return 0
        else
            log_error "Invalid YouTube URL. Please try again."
        fi
    done
}

_interactive_multi_urls() {
    echo "Enter URLs (one per line). Press Enter on an empty line to finish."
    INTERACTIVE_SOURCES=()
    local url

    while true; do
        read -r -p "URL: " url
        [ -z "$url" ] && break
        if is_valid_url "$url"; then
            INTERACTIVE_SOURCES+=("$url")
        else
            log_error "Invalid URL skipped."
        fi
    done

    if [ "${#INTERACTIVE_SOURCES[@]}" -eq 0 ]; then
        log_error "No valid URLs entered."
        return 1
    fi
    INTERACTIVE_SOURCE_FILE=""
    return 0
}

_interactive_file_url() {
    local file_path

    while true; do
        file_path=$(prompt_user "Enter path to URL file" "")
        if [ -z "$file_path" ]; then
            log_error "File path cannot be empty."
            continue
        fi
        if require_file "$file_path"; then
            INTERACTIVE_SOURCE_FILE="$file_path"
            INTERACTIVE_SOURCES=()
            return 0
        fi
    done
}

# ── Step 2: Playlist detection ──────────────────────────────────────────

_interactive_check_playlists() {
    local has_playlist=false

    if [ -n "${INTERACTIVE_SOURCE_FILE:-}" ]; then
        # Check file for playlist URLs (ignoring comments)
        if grep -v '^[[:space:]]*#' "$INTERACTIVE_SOURCE_FILE" 2>/dev/null | grep -q "playlist"; then
            has_playlist=true
        fi
    else
        local url
        for url in "${INTERACTIVE_SOURCES[@]}"; do
            if [[ "$url" == *playlist* ]]; then
                has_playlist=true
                break
            fi
        done
    fi

    if [ "$has_playlist" = true ]; then
        log_warn "Playlist detected!"
        if prompt_yes_no "Download entire playlist?" "y"; then
            CONFIG_PLAYLIST_MODE=true
        else
            CONFIG_PLAYLIST_MODE=false
        fi
    fi
}

# ── Step 3: Configuration ─────────────────────────────────────────────

_interactive_collect_config() {
    log_step "Step 2: Configuration"

    CONFIG_FORMAT=$(prompt_user "Output audio format" "$CONFIG_FORMAT")
    CONFIG_OUTPUT_DIR=$(prompt_user "Output directory" "$CONFIG_OUTPUT_DIR")

    local archive_default=""
    [ -n "$CONFIG_ARCHIVE_FILE" ] && archive_default="$CONFIG_ARCHIVE_FILE"
    local archive
    archive=$(prompt_user "Archive file (leave empty to disable)" "$archive_default")
    CONFIG_ARCHIVE_FILE="$archive"
}

# ── Step 4: Confirmation ───────────────────────────────────────────────

_interactive_confirm_and_run() {
    log_header "Configuration Summary"

    if [ -n "${INTERACTIVE_SOURCE_FILE:-}" ]; then
        echo "  Source:    $INTERACTIVE_SOURCE_FILE"
    else
        echo "  Source:    ${#INTERACTIVE_SOURCES[@]} URL(s)"
    fi
    echo "  Format:    ${CONFIG_FORMAT}"
    echo "  Directory: ${CONFIG_OUTPUT_DIR}"
    echo "  Playlist:  ${CONFIG_PLAYLIST_MODE}"
    echo "  Archive:   ${CONFIG_ARCHIVE_FILE:-None}"
    echo ""

    if prompt_yes_no "Confirm and start download?" "y"; then
        echo ""
        log_success "Starting conversion..."
        echo ""

        if [ -n "${INTERACTIVE_SOURCE_FILE:-}" ]; then
            process_file "$INTERACTIVE_SOURCE_FILE"
        else
            process_urls "${INTERACTIVE_SOURCES[@]}"
        fi
    else
        log_warn "Operation cancelled by user."
    fi
}
