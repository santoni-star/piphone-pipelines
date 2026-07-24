# 🔧 piphone-pipelines

**Utility scripts for media conversion — simple, fast, powered by `ffmpeg`.**

A collection of lightweight shell wrapper scripts that remove the friction from common media conversion tasks. Each script is a single-purpose, well-documented `bash` one-liner designed to just work.

---

## ✨ Scripts

| Script              | What it does                              |
|---------------------|-------------------------------------------|
| `convert.sh`        | Universal media converter (any format → any format) |
| `mp4-to-mp3.sh`     | Extract audio track from MP4 → MP3        |
| `video-to-gif.sh`   | Convert video clips to animated GIFs      |
| `youtube-to-mp3.sh` | Download YouTube audio as MP3             |

---

## 🚀 Quick Start

```bash
# Clone the repo
git clone https://github.com/santoni-star/piphone-pipelines.git
cd piphone-pipelines

# Make scripts executable
chmod +x *.sh

# Usage examples
./mp4-to-mp3.sh input.mp4
./video-to-gif.sh input.mp4 output.gif
./convert.sh input.mkv output.mp4
./youtube-to-mp3.sh "https://youtube.com/watch?v=..."
```

### Requirements

- **[ffmpeg](https://ffmpeg.org/)** — core media processing engine
- **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** — YouTube downloading (for `youtube-to-mp3.sh`)

Install dependencies:

```bash
# Debian / Ubuntu
sudo apt install ffmpeg yt-dlp

# Arch Linux
sudo pacman -S ffmpeg yt-dlp

# macOS (Homebrew)
brew install ffmpeg yt-dlp
```

---

## 📜 Script Reference

### `convert.sh`
```
Usage: ./convert.sh <input> <output>
Example: ./convert.sh video.mkv video.mp4
```
Uses `ffmpeg` to transcode between any supported formats — automatically detects codecs.

### `mp4-to-mp3.sh`
```
Usage: ./mp4-to-mp3.sh <input.mp4>
Output: <input>.mp3
```
Extracts the best-quality audio stream, converts to 320kbps MP3.

### `video-to-gif.sh`
```
Usage: ./video-to-gif.sh <input.mp4> [output.gif]
Example: ./video-to-gif.sh clip.mp4 animation.gif
```
Creates a high-quality animated GIF with optimized palette.

### `youtube-to-mp3.sh`
```
Usage: ./youtube-to-mp3.sh <youtube-url>
Output: <title>.mp3
```
Downloads and converts YouTube audio at best available quality using `yt-dlp`.

---

## 🧰 Tech Stack

| Component   | Technology  |
|-------------|-------------|
| Language    | Bash / Shell|
| Engine      | ffmpeg      |
| Downloader  | yt-dlp      |

---

## 🏷️ Badges

![Shell](https://img.shields.io/badge/language-Bash-4EAA25?logo=gnubash)
![License](https://img.shields.io/badge/license-MIT-green)
![ffmpeg](https://img.shields.io/badge/powered%20by-ffmpeg-blue?logo=ffmpeg)

---

## 📜 License

MIT — see [LICENSE](LICENSE).
