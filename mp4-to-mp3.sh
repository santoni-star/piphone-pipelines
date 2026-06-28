#!/data/data/com.termux/files/usr/bin/bash
# MP4 to MP3 Conversion Pipeline
# Uses ffmpeg to extract audio from MP4 files

set -euo pipefail

# Default values
INPUT_FILE=""
OUTPUT_FILE=""
BITRATE="192k"
SAMPLE_RATE="44100"
CHANNELS="2"
OVERWRITE=false
VERBOSE=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print usage
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <input.mp4> [output.mp3]

Convert MP4 video files to MP3 audio using ffmpeg.

Options:
    -b, --bitrate BITRATE    Audio bitrate (default: 192k)
    -r, --rate RATE          Sample rate in Hz (default: 44100)
    -c, --channels CHANNELS  Number of audio channels (default: 2)
    -y, --overwrite          Overwrite output file if exists
    -v, --verbose            Verbose output
    -h, --help               Show this help message

Arguments:
    input.mp4                Input MP4 file (required)
    output.mp3               Output MP3 file (optional, defaults to input name with .mp3 extension)

Examples:
    $(basename "$0") video.mp4
    $(basename "$0") -b 320k video.mp4 audio.mp3
    $(basename "$0") --bitrate 128k --rate 48000 input.mp4

EOF
}

# Log functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Check if ffmpeg is available
check_ffmpeg() {
    if ! command -v ffmpeg &> /dev/null; then
        log_error "ffmpeg is not installed. Please install it first:"
        log_error "  pkg install ffmpeg"
        exit 1
    fi
}

# Validate input file
validate_input() {
    if [[ ! -f "$INPUT_FILE" ]]; then
        log_error "Input file not found: $INPUT_FILE"
        exit 1
    fi

    # Check if it's actually a video file
    if ! ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 "$INPUT_FILE" 2>/dev/null | grep -q "video"; then
        log_warning "Input file may not contain a video stream"
    fi
}

# Determine output filename
determine_output() {
    if [[ -z "$OUTPUT_FILE" ]]; then
        OUTPUT_FILE="${INPUT_FILE%.*}.mp3"
    fi

    # Check if output exists and overwrite flag
    if [[ -f "$OUTPUT_FILE" && "$OVERWRITE" == false ]]; then
        log_error "Output file already exists: $OUTPUT_FILE"
        log_error "Use -y/--overwrite to force overwrite"
        exit 1
    fi
}

# Perform conversion
convert() {
    local ffmpeg_args=()

    # Build ffmpeg arguments
    ffmpeg_args+=(-i "$INPUT_FILE")
    ffmpeg_args+=(-vn)                    # No video
    ffmpeg_args+=(-acodec libmp3lame)     # MP3 encoder
    ffmpeg_args+=(-ab "$BITRATE")         # Audio bitrate
    ffmpeg_args+=(-ar "$SAMPLE_RATE")     # Sample rate
    ffmpeg_args+=(-ac "$CHANNELS")        # Audio channels

    if [[ "$OVERWRITE" == true ]]; then
        ffmpeg_args+=(-y)
    fi

    if [[ "$VERBOSE" == true ]]; then
        ffmpeg_args+=(-loglevel info)
    else
        ffmpeg_args+=(-loglevel warning)
    fi

    ffmpeg_args+=("$OUTPUT_FILE")

    log_info "Converting: $INPUT_FILE -> $OUTPUT_FILE"
    log_info "Settings: ${BITRATE}, ${SAMPLE_RATE}Hz, ${CHANNELS} channels"

    if [[ "$VERBOSE" == true ]]; then
        log_info "Running: ffmpeg ${ffmpeg_args[*]}"
    fi

    # Run ffmpeg
    if ffmpeg "${ffmpeg_args[@]}"; then
        log_success "Conversion completed: $OUTPUT_FILE"

        # Show file info
        if command -v ffprobe &> /dev/null; then
            local duration
            duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT_FILE" 2>/dev/null || echo "unknown")
            local size
            size=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null || echo "unknown")
            log_info "Duration: ${duration}s"
            log_info "Size: ${size} bytes"
        fi
    else
        log_error "Conversion failed"
        exit 1
    fi
}

# Parse arguments
parse_args() {
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
            -c|--channels)
                CHANNELS="$2"
                shift 2
                ;;
            -y|--overwrite)
                OVERWRITE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                if [[ -z "$INPUT_FILE" ]]; then
                    INPUT_FILE="$1"
                elif [[ -z "$OUTPUT_FILE" ]]; then
                    OUTPUT_FILE="$1"
                else
                    log_error "Too many positional arguments"
                    usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
}

# Main function
main() {
    parse_args "$@"

    if [[ -z "$INPUT_FILE" ]]; then
        log_error "No input file specified"
        usage
        exit 1
    fi

    check_ffmpeg
    validate_input
    determine_output
    convert
}

# Run main
main "$@"