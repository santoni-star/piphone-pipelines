#!/usr/bin/env python3
"""
YouTube to MP3 Downloader
Downloads YouTube videos and converts them to MP3 format using yt-dlp.
"""

import sys
import os
import subprocess
import argparse


def check_yt_dlp():
    """Check if yt-dlp is installed."""
    try:
        subprocess.run(['yt-dlp', '--version'], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def check_ffmpeg():
    """Check if ffmpeg is installed (needed for audio conversion)."""
    try:
        subprocess.run(['ffmpeg', '-version'], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def download_audio(url, output_dir='.', format='mp3', quality='192'):
    """
    Download YouTube video and convert to audio format.
    
    Args:
        url: YouTube URL
        output_dir: Output directory
        format: Audio format (mp3, m4a, opus, etc.)
        quality: Audio quality in kbps
    """
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Build yt-dlp command
    cmd = [
        'yt-dlp',
        '--extract-audio',
        '--audio-format', format,
        '--audio-quality', quality,
        '-o', os.path.join(output_dir, '%(title)s.%(ext)s'),
        url
    ]
    
    print(f"Downloading: {url}")
    print(f"Output directory: {output_dir}")
    print(f"Format: {format}, Quality: {quality}kbps")
    print("-" * 50)
    
    try:
        result = subprocess.run(cmd, check=True)
        print("-" * 50)
        print("Download completed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error: Download failed with exit code {e.returncode}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description='Download YouTube videos and convert to MP3',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s "https://www.youtube.com/watch?v=VIDEO_ID"
  %(prog)s "https://youtu.be/VIDEO_ID" -o ~/Music
  %(prog)s "URL" -f m4a -q 256
        """
    )
    
    parser.add_argument('url', help='YouTube video URL')
    parser.add_argument('-o', '--output', default='.', 
                        help='Output directory (default: current directory)')
    parser.add_argument('-f', '--format', default='mp3',
                        choices=['mp3', 'm4a', 'opus', 'flac', 'wav'],
                        help='Audio format (default: mp3)')
    parser.add_argument('-q', '--quality', default='192',
                        choices=['64', '128', '192', '256', '320'],
                        help='Audio quality in kbps (default: 192)')
    
    args = parser.parse_args()
    
    # Check dependencies
    if not check_yt_dlp():
        print("Error: yt-dlp is not installed.")
        print("Install it with: pip install yt-dlp")
        sys.exit(1)
    
    if not check_ffmpeg():
        print("Error: ffmpeg is not installed.")
        print("Install it with: pkg install ffmpeg (Termux) or apt install ffmpeg (Linux)")
        sys.exit(1)
    
    # Download
    success = download_audio(args.url, args.output, args.format, args.quality)
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()