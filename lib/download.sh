#!/bin/bash
# download.sh — Core download and conversion logic
# Relies on CONFIG_* variables set by cli.sh and YOUTUBE_DL set by dependencies.sh.

# ── Build yt-dlp arguments ─────────────────────────────────────────────
# Constructs the argument array for yt-dlp based on current configuration.
# Args: $1=URL
# Sets the global YDL_ARGS array. Must be consumed immediately by the
# caller (process_url) before any subsequent call overwrites it.

_build_ydl_args() {
    local url="$1"
    local playlist_flag

    if [ "$CONFIG_PLAYLIST_MODE" = true ]; then
        playlist_flag="--yes-playlist"
    else
        playlist_flag="--no-playlist"
    fi

    YDL_ARGS=(
        "$playlist_flag"
        "--extract-audio"
        "--audio-format" "$CONFIG_FORMAT"
        "--audio-quality" "$DEFAULT_AUDIO_QUALITY"
        "--output" "${CONFIG_OUTPUT_DIR}/${OUTPUT_TEMPLATE}"
    )

    if [ -n "$CONFIG_ARCHIVE_FILE" ]; then
        YDL_ARGS=("--download-archive" "$CONFIG_ARCHIVE_FILE" "${YDL_ARGS[@]}")
    fi

    YDL_ARGS+=("--" "$url")
}

# ── Dry-run preview ────────────────────────────────────────────────────
# Shows what would be downloaded without actually downloading.
# Args: $1=URL, $2=index (1-based)

_dry_run_url() {
    local url="$1"
    local index="$2"

    if ! is_valid_url "$url"; then
        log_error "Invalid URL: $url"
        return 1
    fi

    local title
    title=$($YOUTUBE_DL --no-playlist --get-title -- "$url" 2>/dev/null | head -n 1) || title=""

    if [ -z "$title" ]; then
        title="(title unavailable)"
    fi

    printf '  [%d] %s\n    URL: %s\n    Format: %s → %s\n' \
        "$index" "$title" "$url" "$CONFIG_FORMAT" "$CONFIG_OUTPUT_DIR"

    return 0
}

# ── Process single URL ─────────────────────────────────────────────────
# Download and convert one URL.
# Args: $1=URL, $2=index (1-based)
# Returns: 0 on success, 1 on failure.

process_url() {
    local url="$1"
    local index="$2"

    log_step "Processing video ${index}: ${url}"

    if ! is_valid_url "$url"; then
        log_error "Invalid or unsupported YouTube URL: $url"
        return 1
    fi

    # --- Dry-run mode ---
    # Dry-run preview is handled by process_urls() before this
    # function is called. If we reach here in dry-run mode, skip download.
    if [ "$CONFIG_DRY_RUN" = true ]; then
        return 0
    fi

    # --- Extract title for progress display ---
    local title
    title=$($YOUTUBE_DL --no-playlist --get-title -- "$url" 2>/dev/null | head -n 1) || title=""

    if [ -z "$title" ]; then
        title="video_${index}"
    fi

    log_info "Title: ${title}"

    # --- Build args and run ---
    _build_ydl_args "$url"

    if $YOUTUBE_DL "${YDL_ARGS[@]}"; then
        log_success "Converted to ${CONFIG_FORMAT}"
        return 0
    else
        log_error "Conversion failed for: ${url}"
        return 1
    fi
}

# ── Process URLs from file ─────────────────────────────────────────────
# Read a file of URLs (one per line, # comments supported) and process them.
# Args: $1=file path

process_file() {
    local file="$1"

    require_file "$file" || exit "$EXIT_INVALID_ARG"

    log_info "Reading URLs from: ${file}"

    local urls=()
    local line

    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        urls+=("$line")
    done < "$file"

    if [ "${#urls[@]}" -eq 0 ]; then
        log_error "No URLs found in: ${file}"
        exit "$EXIT_NO_URLS"
    fi

    process_urls "${urls[@]}"
}

# ── Process multiple URLs ──────────────────────────────────────────────
# Iterate over URLs, process each, display summary.
# Args: $@=URLs

process_urls() {
    local urls=("$@")
    local total=${#urls[@]}

    if [ "$total" -eq 0 ]; then
        log_error "No URLs to process."
        exit "$EXIT_NO_URLS"
    fi

    # --- Dry-run mode ---
    if [ "$CONFIG_DRY_RUN" = true ]; then
        log_header "Dry-run preview — ${total} video(s)"
        local i
        for i in "${!urls[@]}"; do
            _dry_run_url "${urls[$i]}" "$((i + 1))"
        done
        echo ""
        log_info "Format: ${CONFIG_FORMAT} | Output: ${CONFIG_OUTPUT_DIR}"
        [ -n "$CONFIG_ARCHIVE_FILE" ] && log_info "Archive: ${CONFIG_ARCHIVE_FILE}"
        [ "$CONFIG_PLAYLIST_MODE" = true ] && log_info "Playlist mode: enabled"
        return 0
    fi

    # --- Normal mode ---
    log_info "Processing ${total} video(s)..."

    local success_count=0
    local fail_count=0
    local i

    for i in "${!urls[@]}"; do
        local url="${urls[$i]}"
        local index=$((i + 1))

        if process_url "$url" "$index"; then
            ((success_count++)) || true
        else
            ((fail_count++)) || true
        fi

        echo ""  # separator between videos
    done

    # --- Summary ---
    log_header "Summary"
    log_success "Success: ${success_count}"
    [ "$fail_count" -gt 0 ] && log_error "Failures: ${fail_count}"
    log_info "Total: ${total}"

    if [ "$fail_count" -eq 0 ]; then
        log_success "All conversions succeeded!"
        log_info "Audio files available in: ${CONFIG_OUTPUT_DIR}"
        return 0
    else
        log_warn "Some conversions failed. Check the error messages above."
        return 1
    fi
}
