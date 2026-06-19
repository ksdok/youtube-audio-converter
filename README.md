# YouTube Audio Converter

A professional Bash script to extract audio from YouTube videos and convert them into audio files (MP3 by default) with the best possible quality.

## Features

- **Multi-source** : Convert a single URL, multiple URLs, or a text file.
- **Playlist Mode** : Full support for YouTube and YouTube Music playlists (`--playlist`).
- **Anti-Duplicate** : Archiving system to avoid re-downloading already processed videos (`--archive`).
- **Dry-Run Preview** : Preview titles, URLs, format, output folder, and playlist state without downloading (`--dry-run`).
- **Interactive Assistant** : Guided mode for source selection and configuration (`-i`, `--interactive`).
- **Maximum Quality** : Automatic extraction of the best available audio quality (quality 0).
- **Flexibility** : Configurable output directory and audio format.
- **Robust** : Automatic dependency check (`yt-dlp`, `ffmpeg`) and error handling.

## Prerequisites

The script requires the following tools:

1. **yt-dlp** (strongly recommended) or **youtube-dl**.
2. **ffmpeg** (essential for audio conversion).

### Quick Installation of Dependencies

#### macOS (via Homebrew)
```bash
brew install yt-dlp ffmpeg
```

#### Ubuntu/Debian
```bash
sudo apt update && sudo apt install yt-dlp ffmpeg
```

#### Fedora
```bash
sudo dnf install yt-dlp ffmpeg
```

#### Via pip
```bash
pip install yt-dlp
```

> **Note**: `ffmpeg` must be installed as a system binary. The Python package `ffmpeg-python` is not sufficient.

### Getting the Project

```bash
git clone https://github.com/kim/youtube-audio-converter.git
cd youtube-audio-converter
```

### Installing the Command

Run the installer from the project root:

```bash
./install.sh
```

This copies the script and its `lib/` modules to `~/.local/share/youtube-audio-converter/` and creates a `youtube-to-mp3` wrapper in `~/.local/bin/`.

After installation, the command is available from anywhere:

```bash
youtube-to-mp3 --help
youtube-to-mp3 urls.txt
```

If `~/.local/bin` is not in your `PATH`, the installer prints the exact line to add to your shell configuration.

## Usage

### 1. Simple Download (single videos)
For one or more videos:
```bash
./youtube_to_mp3.sh "https://www.youtube.com/watch?v=ID1" "https://www.youtube.com/watch?v=ID2"
```

### 2. Using a URL File
Create a `urls.txt` file with one URL per line, then:
```bash
./youtube_to_mp3.sh urls.txt
```

### 3. Downloading a Full Playlist
By default, the script only downloads the first video of a playlist to avoid accidental mass downloads. Use the `--playlist` option to process the entire list:
```bash
./youtube_to_mp3.sh --playlist "https://www.youtube.com/playlist?list=PLAYLIST_ID"
```

### 4. Avoiding Duplicates with an Archive
To avoid re-downloading videos already converted in previous sessions:
```bash
./youtube_to_mp3.sh --archive archive.txt urls.txt
```
*The script will create `archive.txt` and record the ID of each processed video.*

### 5. Customizing Folder and Format
```bash
# Output to a specific folder and WAV format
./youtube_to_mp3.sh -o "./my_music" -f wav "https://www.youtube.com/watch?v=ID"
```

### 6. Previewing Without Downloading
```bash
./youtube_to_mp3.sh --dry-run "https://www.youtube.com/watch?v=ID"
```
*The dry-run preview shows the detected title, source URL, target format, output directory, and playlist mode without creating audio files.*

### 7. Using the Interactive Assistant
```bash
./youtube_to_mp3.sh --interactive
```
*Interactive mode guides you through source selection, playlist confirmation when needed, output format, output directory, archive selection, and a final confirmation step.*

## CLI Options

| Option | Description | Default Value |
| :--- | :--- | :--- |
| `-h, --help` | Displays help | - |
| `-o, --output` | Output directory for audio files | `./mp3` |
| `-f, --format` | Audio format (`mp3`, `m4a`, `wav`, etc.) | `mp3` |
| `--playlist` | Allows full download of a playlist | Disabled |
| `--archive FILE` | File to track already downloaded videos | None |
| `-i, --interactive` | Start the interactive assistant | Disabled |
| `--dry-run` | Preview what would be processed without downloading | Disabled |

## URL File Format

The script accepts simple text files. Empty lines and comments starting with `#` are ignored.

```text
# My classics
https://www.youtube.com/watch?v=abc12345
https://www.youtube.com/watch?v=def67890

# To process later
# https://www.youtube.com/watch?v=ghi11122
```

## Output and Naming

Files are saved as: `Video Title [YouTube_ID].mp3`.
Including the ID prevents overwriting files with the same title.

## Remarks and Troubleshooting

### Permission Issues
If the script refuses to run, make it executable:
```bash
chmod +x youtube_to_mp3.sh
```

### Download Errors
- **Invalid URL**: Ensure the URL is a valid YouTube address.
- **Restricted Content**: Some videos (age or region restricted) may block the download.
- **Updating yt-dlp**: YouTube frequently changes its algorithms. If the download fails, update `yt-dlp`:
  - `pip install -U yt-dlp` or `brew upgrade yt-dlp`.

### Copyright
The use of this script must comply with YouTube's Terms of Service and intellectual property rights.

## License

This project is distributed under the **MIT License**. See the `LICENSE` file for more details.
