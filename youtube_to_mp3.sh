#!/bin/bash

set -euo pipefail

# Script to extract audio from YouTube videos and convert them to audio files
# Usage: ./youtube_to_mp3.sh urls.txt
#        ./youtube_to_mp3.sh url1 url2 url3...

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display help
show_help() {
    echo "Usage: $0 [OPTIONS] [URLS...|FILE]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Display this help"
    echo "  -o, --output   Output directory (default: ./mp3)"
    echo "  -f, --format   Output audio format (default: mp3)"
    echo "  --playlist     Process YouTube playlists (default: process single video only)"
    echo "  --archive FILE Use yt-dlp download archive to avoid duplicates"
    echo ""
    echo "Examples:"
    echo "  $0 https://www.youtube.com/watch?v=example1 https://www.youtube.com/watch?v=example2"
    echo "  $0 urls.txt"
    echo "  $0 -o /path/to/directory urls.txt"
    echo "  $0 --playlist https://www.youtube.com/playlist?list=..."
    echo "  $0 --archive downloaded.txt urls.txt"
}

is_valid_url() {
    local url="$1"

    case "$url" in
        *://www.youtube.com/playlist*|*://youtube.com/playlist*|*://music.youtube.com/playlist*)
            return 0
            ;;
        http://www.youtube.com/watch\?*|https://www.youtube.com/watch\?*|http://youtube.com/watch\?*|https://youtube.com/watch\?*|http://music.youtube.com/watch\?*|https://music.youtube.com/watch\?*|http://youtu.be/*|https://youtu.be/*|http://www.youtube.com/shorts/*|https://www.youtube.com/shorts/*|http://youtube.com/shorts/*|https://youtube.com/shorts/*|http://www.youtube.com/live/*|https://www.youtube.com/live/*|http://youtube.com/live/*|https://youtube.com/live/*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Default values
OUTPUT_DIR="./mp3"
AUDIO_FORMAT="mp3"
PLAYLIST_MODE=false
ARCHIVE_FILE=""

# Argument processing
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: option $1 requires an output directory.${NC}" >&2
                exit 1
            fi
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -f|--format)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: option $1 requires an audio format.${NC}" >&2
                exit 1
            fi
            AUDIO_FORMAT="$2"
            shift 2
            ;;
        --playlist)
            PLAYLIST_MODE=true
            shift
            ;;
        --archive)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: option $1 requires a file path.${NC}" >&2
                exit 1
            fi
            ARCHIVE_FILE="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            show_help
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Dependency check
check_dependencies() {
    echo -e "${BLUE}Checking dependencies...${NC}"
    
    if ! command -v youtube-dl &> /dev/null && ! command -v yt-dlp &> /dev/null; then
        echo -e "${RED}Error: Neither youtube-dl nor yt-dlp is installed.${NC}" >&2
        echo "yt-dlp installation recommended:"
        echo "  macOS: brew install yt-dlp"
        echo "  Ubuntu/Debian: sudo apt install yt-dlp"
        echo "  Fedora: sudo dnf install yt-dlp"
        echo "  Or via pip: pip install yt-dlp"
        exit 1
    fi
    
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${RED}Error: ffmpeg is not installed.${NC}" >&2
        echo "Required installation:"
        echo "  macOS: brew install ffmpeg"
        echo "  Ubuntu/Debian: sudo apt install ffmpeg"
        echo "  Fedora: sudo dnf install ffmpeg"
        exit 1
    fi
    
    # Use yt-dlp if available, otherwise youtube-dl
    if command -v yt-dlp &> /dev/null; then
        YOUTUBE_DL="yt-dlp"
    else
        YOUTUBE_DL="youtube-dl"
    fi
    
    echo -e "${GREEN}Dependencies verified successfully.${NC}"
    echo -e "${BLUE}Using: $YOUTUBE_DL${NC}"
}

# Create output directory
create_output_dir() {
    if [ ! -d "$OUTPUT_DIR" ]; then
        echo -e "${BLUE}Creating output directory: $OUTPUT_DIR${NC}"
        mkdir -p -- "$OUTPUT_DIR"
    fi
}

# Process single URL
process_url() {
    local url="$1"
    local index="$2"
    
    printf '%bProcessing video %s:%b %s\n' "$YELLOW" "$index" "$NC" "$url"

    if ! is_valid_url "$url"; then
        printf '%bInvalid or unsupported YouTube URL:%b %s\n' "$RED" "$NC" "$url" >&2
        return 1
    fi
    
    # Extract video title
    local title
    title=$($YOUTUBE_DL --no-playlist --get-title -- "$url" 2>/dev/null | head -n 1) || title=""
    
    if [ -z "$title" ]; then
        title="video_$index"
    fi
    
    printf '%bTitle:%b %s\n' "$BLUE" "$NC" "$title"
    
    # Build yt-dlp arguments
    local playlist_flag="--no-playlist"
    if [ "$PLAYLIST_MODE" = true ]; then
        playlist_flag="--yes-playlist"
    fi
    
    local yt_args=("$playlist_flag" "--extract-audio" "--audio-format" "$AUDIO_FORMAT" "--audio-quality" "0" "--output" "$OUTPUT_DIR/%(title).100s [%(id)s].%(ext)s" "--" "$url")
    
    # Add archive flag if provided
    if [ -n "$ARCHIVE_FILE" ]; then
        yt_args=("--download-archive" "$ARCHIVE_FILE" "${yt_args[@]}")
    fi
    
    if $YOUTUBE_DL "${yt_args[@]}"; then
        echo -e "${GREEN}✓ Conversion completed to format $AUDIO_FORMAT${NC}"
    else
        echo -e "${RED}✗ Conversion failed for: $url${NC}" >&2
        return 1
    fi
}

# Process URLs from file
process_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: File $file does not exist.${NC}" >&2
        exit 1
    fi
    
    echo -e "${BLUE}Reading URLs from: $file${NC}"
    
    local urls=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        if [[ "$line" =~ ^[[:space:]]*$ || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        else
            urls+=("$line")
        fi
    done < "$file"
    
    if [ "${#urls[@]}" -eq 0 ]; then
        echo -e "${RED}No URLs to process.${NC}" >&2
        exit 1
    fi
    
    process_urls "${urls[@]}"
}

# Process URLs
process_urls() {
    local urls=("$@")
    local total=${#urls[@]}
    
    if [ "$total" -eq 0 ]; then
        echo -e "${RED}No URLs to process.${NC}" >&2
        exit 1
    fi
    
    echo -e "${BLUE}Processing $total video(s)...${NC}"
    
    local success_count=0
    local fail_count=0
    
    for i in "${!urls[@]}"; do
        local url="${urls[$i]}"
        local index=$((i+1))
        
        if process_url "$url" "$index"; then
            ((success_count+=1))
        else
            ((fail_count+=1))
        fi
        
        echo ""  # Blank line to separate processing
    done
    
    # Summary
    echo -e "${BLUE}=== Summary ===${NC}"
    echo -e "${GREEN}Success: $success_count${NC}"
    echo -e "${RED}Failures: $fail_count${NC}"
    echo -e "${BLUE}Total: $total${NC}"
    
    if [ "$fail_count" -eq 0 ]; then
        echo -e "${GREEN}All conversions succeeded!${NC}"
        echo -e "${BLUE}Audio files available in: $OUTPUT_DIR${NC}"
    else
        echo -e "${YELLOW}Some conversions failed. Check the error messages above.${NC}"
        return 1
    fi
}

# Main function
main() {
    # Display header
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  YouTube Audio Converter${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # Argument processing
    if [ $# -eq 0 ]; then
        echo -e "${RED}Error: No URL or file provided.${NC}" >&2
        show_help
        exit 1
    fi

    # Check dependencies after minimal argument validation
    # to return most useful CLI errors first
    check_dependencies
    
    # Create output directory
    create_output_dir
    
    if [ $# -eq 1 ] && [ -f "$1" ]; then
        # If single argument and it's a file, treat as URL file
        process_file "$1"
    else
        # Otherwise, treat all arguments as URLs
        process_urls "$@"
    fi
}

# Execute
main "$@"
