#!/bin/bash
# YouTube to MP3 Pipeline - Shell wrapper
# Usage: ./run.sh "YouTube URL" [output_dir] [format] [quality]

set -e

URL="$1"
OUTPUT_DIR="${2:-.}"
FORMAT="${3:-mp3}"
QUALITY="${4:-192}"

if [ -z "$URL" ]; then
    echo "Usage: $0 \"YouTube URL\" [output_dir] [format] [quality]"
    echo "Example: $0 \"https://youtube.com/watch?v=...\" ./downloads mp3 192"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/download.py" "$URL" -o "$OUTPUT_DIR" -f "$FORMAT" -q "$QUALITY"