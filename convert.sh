#!/bin/bash
# mp4-to-mp3 conversion pipeline
# Usage: ./convert.sh input.mp4 [output.mp3]

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 input.mp4 [output.mp3]"
    echo "If output.mp3 is not specified, it will use the same name as input with .mp3 extension"
    exit 1
fi

INPUT_FILE="$1"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

if [ $# -eq 2 ]; then
    OUTPUT_FILE="$2"
else
    # Remove .mp4 extension and add .mp3
    OUTPUT_FILE="${INPUT_FILE%.mp4}.mp3"
fi

echo "Converting: $INPUT_FILE -> $OUTPUT_FILE"

# Convert using ffmpeg
# -i: input file
# -vn: disable video recording (audio only)
# -acodec libmp3lame: use LAME MP3 encoder
# -q:a 2: quality setting (0-9, lower is better, 2 is ~190kbps VBR)
ffmpeg -i "$INPUT_FILE" -vn -acodec libmp3lame -q:a 2 "$OUTPUT_FILE" -y

if [ $? -eq 0 ]; then
    echo "Conversion successful: $OUTPUT_FILE"
    # Show file info
    ls -lh "$OUTPUT_FILE"
else
    echo "Conversion failed"
    exit 1
fi