# Prompt: Build GemmaCodeGUI — Local AI Coding Assistant (SwiftUI)

Use this prompt with Qwen (or any LLM) to generate the complete project.

---

## The Prompt

> Build a macOS project called **GemmaCodeGUI** — a local AI coding assistant powered by Google's **Gemma 3 4B** model running through Ollama.
>
> **This project must have the same structure as a working Qwen project I already have, adapted for Gemma.**
>
> ### Required Files
>
> #### 1. `index.html` — Web-based Chat GUI
> - Full-screen dark-themed interface (`#0d0d0d` background, `#1a1a1a` surface)
> - Header showing "Gemma 3 · 4B · LOCAL" with a tooltip on hover showing model info
> - A monospaced output area (`SF Mono`, `Fira Code`, or `JetBrains Mono`) with a blinking blue cursor animation (`#007aff`)
> - Input field at the bottom with an "Generate" button
> - On submit, stream the response from `http://127.0.0.1:11434/api/generate` using `fetch()` with `ReadableStream`
> - JSON body: `{ "model": "gemma3:4b", "prompt": "<user input>", "stream": true }`
> - Parse each newline-delimited JSON chunk, extract the `"response"` field, and append it to the output area in real-time
> - Auto-scroll to bottom as content streams in
> - Show an error message with setup instructions if the fetch fails
> - Support pressing Enter to submit
> - Use CSS variables for all colors, no external dependencies, no frameworks
>
> #### 2. `GemmaGUI.swift` — Native macOS SwiftUI App
> - An `ObservableObject` class called `GemmaEngine` with:
>   - `@Published var output: String`
>   - `@Published var instruction: String`
>   - `@Published var isGenerating: Bool`
>   - A `generate()` function that POSTs to `http://localhost:11434/api/generate` with model `"gemma3:4b"` and streams the response using `URLSession.bytes(for:)`
>   - Parse each line as JSON and extract the `"response"` field, appending to `output` on `MainActor`
> - A `ContentView` with:
>   - A read-only `TextEditor` showing `engine.output` with monospaced font
>   - A `Divider`
>   - An `HStack` with a `TextField("Ask Gemma...")` and a "Generate" button (or `ProgressView` while generating)
>   - `onSubmit` and `Cmd+Return` keyboard shortcut support
> - App entry using `NSApplication.shared` script format (not `@main`), with an `AppDelegate` that creates an `NSWindow` (600×500) with the `ContentView` as a hosting controller
> - Window should be centered, resizable, and activate as a regular app
>
> #### 3. `gemma.sh` — CLI Shell Script
> - Shebang: `#!/bin/bash`
> - Variable: `MODEL="gemma3:4b"`
> - Accept one argument as the prompt, show usage if empty
> - Use `curl -s` to POST to `http://localhost:11434/api/generate` with `stream: true`
> - Pipe through a `while read -r line` loop
> - Extract the `"response"` field using `sed` (no `jq` dependency)
> - Decode `\n` and `\"` escapes, strip trailing newlines with `tr -d '\n'`
> - Print "--- Thinking ---" before and "--- Done ---" after
>
> #### 4. `start.sh` — Ollama Launcher
> - Kill any existing `ollama` process with `pkill ollama`
> - Export `OLLAMA_ORIGINS="*"` for CORS (needed by the web GUI on `file://` URLs)
> - Start `ollama serve` in background, redirect output to `/dev/null`
> - Wait up to 10 seconds for `http://localhost:11434/api/tags` to respond
> - On success: print ✅ status with model name and usage instructions
> - On failure: print ❌ error with install instructions
>
> #### 5. `README.md` — Project Documentation
> - Title: "Gemma 3 — Local AI Coding Assistant"
> - Description: 100% offline AI pair programmer using Gemma 3 4B via Ollama
> - Features list: Web GUI, Native macOS App, CLI Tool, Fully Offline, M-series Optimized
> - Project structure tree
> - Prerequisites: `brew install ollama` then `ollama pull gemma3:4b`
> - Quick Start: `./start.sh` then `open index.html` or `./gemma.sh "prompt"`
> - Architecture table (Interfaces / Backend / Model) with ASCII diagram
> - "Why Local AI?" comparison table (Privacy, Latency, Offline, Cost, Control)
>
> ### Technical Constraints
> - **Zero external dependencies** — no npm, no pip, no CocoaPods
> - **Single-file Swift** — the SwiftUI app must be runnable with `swift GemmaGUI.swift`
> - **All shell scripts must be POSIX-compatible** (no bashisms beyond basic `for` loops)
> - **All API calls use model name `gemma3:4b`** (not `gemma3:4b-it` or any other variant)
> - **The web GUI must work when opened as a `file://` URL** (hence the CORS setup in `start.sh`)
>
> Generate all 5 files with complete, production-ready code. No placeholders, no TODOs.
