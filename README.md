# GemmaCodeGUI – Local AI Coding Assistant

## Overview

**GemmaCodeGUI** is a macOS project that provides a local AI coding assistant powered by the **Gemma 3 4B** model via **Ollama**. The project includes:
- A dark, luxurious web UI (`index.html`).
- A native macOS SwiftUI application (`GemmaGUI.swift`).
- A POSIX‑compatible CLI wrapper (`gemma.sh`).
- An Ollama launcher script (`start.sh`).
- Comprehensive documentation (`README.md`).

All components are **zero‑dependency** – no npm, pip, or CocoaPods – and work offline.

## Features
- **Premium dark theme** with glass‑morphism, gradient accents, and smooth animations.
- **Streaming AI responses** in both web and native UI.
- **Keyboard shortcuts** (Enter / Cmd+Return) for fast interaction.
- **One‑click Ollama setup** via `start.sh`.
- **Cross‑platform CLI** for scripting and automation.

## Prerequisites
```bash
brew install ollama   # Install Ollama
ollama pull gemma3:4b # Download the model
```

## Quick Start
```bash
# 1. Start Ollama and verify the model
./start.sh

# 2. Open the web UI (file:// URL) in your browser
open index.html

# 3. Or run the native macOS app
swift GemmaGUI.swift

# 4. Or use the CLI
./gemma.sh "Explain quicksort"
```

## Project Structure
```
GemmaCodeGUI/
├─ index.html          # Web UI (luxurious dark theme)
├─ GemmaGUI.swift      # SwiftUI macOS app
├─ gemma.sh            # CLI wrapper
├─ start.sh            # Ollama launcher
└─ README.md           # Documentation (this file)
```

## Architecture
- **Web UI** communicates with Ollama via `fetch` to `http://127.0.0.1:11434/api/generate`.
- **SwiftUI app** uses `URLSession.bytes(for:)` to stream responses.
- **CLI** streams JSON lines with `curl` and extracts the `response` field.
- **start.sh** ensures Ollama is running and CORS is enabled for `file://` URLs.

## Technical Constraints
- No external dependencies.
- Single‑file SwiftUI implementation.
- POSIX‑compatible shell scripts.
- All API calls use model name `gemma3:4b`.
- Web UI works when opened via `file://`.

## License
This project is provided under the MIT License. Feel free to modify and extend.
