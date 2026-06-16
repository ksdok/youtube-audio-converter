#!/usr/bin/env bash
# shellcheck disable=SC1091
# youtube_to_mp3.sh — Extract audio from YouTube videos
# Entry point: sources all modules and delegates to main().

set -euo pipefail

# ── Resolve script directory ───────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# ── Source modules ─────────────────────────────────────────────────────
# shellcheck disable=SC1091
# shellcheck source=lib/constants.sh
source "${LIB_DIR}/constants.sh"
# shellcheck source=lib/utils.sh
source "${LIB_DIR}/utils.sh"
# shellcheck source=lib/cli.sh
source "${LIB_DIR}/cli.sh"
# shellcheck source=lib/dependencies.sh
source "${LIB_DIR}/dependencies.sh"
# shellcheck source=lib/download.sh
source "${LIB_DIR}/download.sh"
# shellcheck source=lib/interactive.sh
source "${LIB_DIR}/interactive.sh"

# ── Main ───────────────────────────────────────────────────────────────

main() {
    # Parse CLI arguments → sets CONFIG_* variables
    parse_args "$@"

    # Validate that we have something to process (unless interactive)
    if [ "${#CONFIG_ARGS[@]}" -eq 0 ] && [ "$CONFIG_INTERACTIVE" = false ]; then
        log_error "No URL or file provided."
        show_help >&2
        exit "$EXIT_INVALID_ARG"
    fi

    # Show banner only when we're about to do real work
    log_header "========================================"
    log_header "  YouTube Audio Converter"
    log_header "========================================"
    echo ""

    # Check dependencies → sets YOUTUBE_DL
    check_dependencies

    # Ensure output directory exists
    ensure_output_dir "$CONFIG_OUTPUT_DIR"

    # Interactive mode delegates entirely to the interactive module
    if [ "$CONFIG_INTERACTIVE" = true ]; then
        run_interactive_mode
        return $?
    fi

    # Determine input source and process
    local result=0
    if [ "${#CONFIG_ARGS[@]}" -eq 1 ] && [ -f "${CONFIG_ARGS[0]}" ]; then
        process_file "${CONFIG_ARGS[0]}" || result=$?
    else
        process_urls "${CONFIG_ARGS[@]}" || result=$?
    fi

    return $result
}

main "$@"
