#!/bin/bash
# MP4 to MP3 Converter Pipeline
# Usage: ./mp4-to-mp3.sh input.mp4 [output.mp3]
#        ./mp4-to-mp3.sh /path/to/directory/

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
BITRATE="192k"
SAMPLE_RATE="44100"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_ffmpeg() {
    if ! command -v ffmpeg &> /dev/null; then
        log_error "ffmpeg is not installed. Please install it first:"
        log_error "  pkg install ffmpeg  # Termux"
        log_error "  apt install ffmpeg  # Debian/Ubuntu"
        exit 1
    fi
    log_info "Found ffmpeg: $(ffmpeg -version | head -1)"
}

convert_single() {
    local input="$1"
    local output="$2"

    if [[ ! -f "$input" ]]; then
        log_error "Input file not found: $input"
        return 1
    fi

    # Generate output filename if not provided
    if [[ -z "$output" ]]; then
        output="${input%.*}.mp3"
    fi

    log_info "Converting: $input -> $output"

    # Run ffmpeg conversion
    if ffmpeg -y -i "$input" \
        -vn \
        -acodec libmp3lame \
        -ab "$BITRATE" \
        -ar "$SAMPLE_RATE" \
        -map_metadata 0 \
        -id3v2_version 3 \
        "$output" 2>&1 | grep -E "(frame|size|time|speed)"; then
        log_info "Successfully converted: $output"
        return 0
    else
        log_error "Conversion failed for: $input"
        return 1
    fi
}

convert_directory() {
    local dir="$1"
    local count=0
    local failed=0

    if [[ ! -d "$dir" ]]; then
        log_error "Directory not found: $dir"
        return 1
    fi

    log_info "Processing directory: $dir"

    # Find all MP4 files (case insensitive)
    while IFS= read -r -d '' file; do
        if convert_single "$file" ""; then
            ((count++))
        else
            ((failed++))
        fi
    done < <(find "$dir" -type f \( -iname "*.mp4" -o -iname "*.m4v" -o -iname "*.mov" \) -print0)

    log_info "Done! Converted: $count, Failed: $failed"
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] INPUT [OUTPUT]

Convert MP4 video files to MP3 audio using ffmpeg.

ARGUMENTS:
    INPUT       Input MP4 file or directory containing MP4 files
    OUTPUT      Output MP3 file (optional, only for single file)

OPTIONS:
    -b, --bitrate BITRATE     Audio bitrate (default: 192k)
    -r, --rate RATE           Sample rate in Hz (default: 44100)
    -h, --help                Show this help message

EXAMPLES:
    $0 video.mp4                    # Convert to video.mp3
    $0 video.mp4 audio.mp3          # Convert to specific output
    $0 /path/to/videos/             # Convert all MP4 in directory
    $0 -b 320k video.mp4            # High quality 320kbps
    $0 -r 48000 video.mp4           # 48kHz sample rate

REQUIREMENTS:
    - ffmpeg installed (pkg install ffmpeg on Termux)
EOF
}

# Parse arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--bitrate)
            BITRATE="$2"
            shift 2
            ;;
        -r|--rate)
            SAMPLE_RATE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*|--*)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"

# Main logic
check_ffmpeg

if [[ $# -eq 0 ]]; then
    log_error "No input provided"
    show_usage
    exit 1
fi

INPUT="$1"
OUTPUT="${2:-}"

if [[ -d "$INPUT" ]]; then
    convert_directory "$INPUT"
elif [[ -f "$INPUT" ]]; then
    convert_single "$INPUT" "$OUTPUT"
else
    log_error "Input not found: $INPUT"
    exit 1
fi