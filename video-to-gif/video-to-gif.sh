#!/bin/bash
# Video to GIF Converter Pipeline
# Usage: ./video-to-gif.sh input.mp4 [output.gif] [width] [fps]

set -e

# Default values
INPUT_FILE="${1}"
OUTPUT_FILE="${2:-output.gif}"
WIDTH="${3:-480}"
FPS="${4:-10}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: Input file '$INPUT_FILE' not found${NC}"
    echo "Usage: $0 input.mp4 [output.gif] [width] [fps]"
    exit 1
fi

# Check if ffmpeg is available
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${RED}Error: ffmpeg is not installed${NC}"
    echo "Install with: pkg install ffmpeg"
    exit 1
fi

echo -e "${GREEN}Converting $INPUT_FILE to $OUTPUT_FILE${NC}"
echo -e "${YELLOW}Settings: width=${WIDTH}px, fps=${FPS}${NC}"

# Generate palette for better quality
PALETTE_FILE="/tmp/palette_$$.png"

echo "Generating color palette..."
ffmpeg -v warning -i "$INPUT_FILE" -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos,palettegen=stats_mode=diff" -y "$PALETTE_FILE"

echo "Creating GIF..."
ffmpeg -v warning -i "$INPUT_FILE" -i "$PALETTE_FILE" \
    -filter_complex "fps=$FPS,scale=$WIDTH:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
    -y "$OUTPUT_FILE"

# Clean up
rm -f "$PALETTE_FILE"

# Show result
if [ -f "$OUTPUT_FILE" ]; then
    SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo -e "${GREEN}Success! Created: $OUTPUT_FILE ($SIZE)${NC}"
else
    echo -e "${RED}Error: GIF creation failed${NC}"
    exit 1
fi