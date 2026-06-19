#!/usr/bin/env bash
# install.sh — Install or uninstall youtube-to-mp3 as a user command
# Copies the script and lib/ to ~/.local/share/youtube-audio-converter/
# and creates a wrapper in ~/.local/bin/youtube-to-mp3.
#
# Usage:
#   ./install.sh             Install (or reinstall)
#   ./install.sh --uninstall Remove the installed files

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────
INSTALL_DIR="${HOME}/.local/share/youtube-audio-converter"
BIN_DIR="${HOME}/.local/bin"
COMMAND_NAME="youtube-to-mp3"

# Resolve the source directory (where this installer lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { printf '%b%b%b\n' "$BLUE" "$*" "$NC"; }
log_success() { printf '%b✓ %b%b\n' "$GREEN" "$*" "$NC"; }
log_error()   { printf '%b✗ %b%b\n' "$RED" "$*" "$NC" >&2; }
log_warn()    { printf '%b⚠ %b%b\n' "$YELLOW" "$*" "$NC" >&2; }

# ── Uninstall ──────────────────────────────────────────────────────────

do_uninstall() {
    local removed=false

    if [ -f "${BIN_DIR}/${COMMAND_NAME}" ]; then
        rm -f -- "${BIN_DIR:?}/${COMMAND_NAME}"
        log_success "Removed: ${BIN_DIR}/${COMMAND_NAME}"
        removed=true
    fi

    # Remove only the files we own, then tidy up the directory if empty
    if [ -d "${INSTALL_DIR}" ]; then
        rm -f -- "${INSTALL_DIR:?}/youtube_to_mp3.sh"
        rm -rf -- "${INSTALL_DIR:?}/lib"
        removed=true
        if rmdir "${INSTALL_DIR}" 2>/dev/null; then
            log_success "Removed: ${INSTALL_DIR}"
        else
            log_success "Removed installed files from: ${INSTALL_DIR}"
            log_warn "Directory kept (not empty): ${INSTALL_DIR}"
        fi
    fi

    if [ "$removed" = false ]; then
        log_warn "Nothing to uninstall — no installed files found."
        exit 0
    fi

    log_info "youtube-to-mp3 has been uninstalled."
    exit 0
}

# ── Parse arguments ────────────────────────────────────────────────────

case "${1:-}" in
    --uninstall)
        do_uninstall
        ;;
    -h|--help)
        echo "Usage: $(basename "$0") [--uninstall] [--help]"
        echo ""
        echo "  (no args)     Install youtube-to-mp3"
        echo "  --uninstall   Remove the installed files"
        echo "  --help        Show this help"
        exit 0
        ;;
    "")
        : # proceed to install
        ;;
    *)
        log_error "Unknown argument: $1"
        echo "Usage: $(basename "$0") [--uninstall] [--help]" >&2
        exit 1
        ;;
esac

# ── Pre-flight checks ──────────────────────────────────────────────────

if [ ! -f "$SCRIPT_DIR/youtube_to_mp3.sh" ]; then
    log_error "youtube_to_mp3.sh not found in $SCRIPT_DIR"
    log_error "Run this installer from the project root."
    exit 1
fi

if [ ! -d "$SCRIPT_DIR/lib" ]; then
    log_error "lib/ directory not found in $SCRIPT_DIR"
    log_error "Run this installer from the project root."
    exit 1
fi

# ── Install ────────────────────────────────────────────────────────────

log_info "Installing youtube-to-mp3 to $INSTALL_DIR..."

# Create target directories
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# Remove previous install to avoid stale files
rm -rf -- "${INSTALL_DIR:?}/youtube_to_mp3.sh" "${INSTALL_DIR:?}/lib"

# Copy the entrypoint and lib/ modules
cp "$SCRIPT_DIR/youtube_to_mp3.sh" "$INSTALL_DIR/"
cp -r "$SCRIPT_DIR/lib" "$INSTALL_DIR/"

chmod +x "$INSTALL_DIR/youtube_to_mp3.sh"

# Create the wrapper script in BIN_DIR
cat > "$BIN_DIR/$COMMAND_NAME" <<EOF
#!/usr/bin/env bash
exec "$INSTALL_DIR/youtube_to_mp3.sh" "\$@"
EOF
chmod +x "$BIN_DIR/$COMMAND_NAME"

log_success "Installed: $COMMAND_NAME → $BIN_DIR/$COMMAND_NAME"

# ── PATH check ─────────────────────────────────────────────────────────

case ":${PATH}:" in
    *":${BIN_DIR}":*)
        log_success "$BIN_DIR is in your PATH."
        log_info "Run: $COMMAND_NAME --help"
        ;;
    *)
        log_warn "$BIN_DIR is not in your PATH."
        log_info "Add this line to your shell config (~/.bashrc or ~/.zshrc):"
        printf "  export PATH=\"%s:\$PATH\"\n" "$BIN_DIR"
        log_info "Then restart your terminal or run: source ~/.bashrc"
        ;;
esac
