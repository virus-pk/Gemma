#!/bin/sh
# Build script for GemmaGUI.swift – fixes permission issues
set -e

# Ensure we are in the project directory
cd "$(dirname "$0")"

# Grant read/write permissions to the source file
chmod u+rw GemmaGUI.swift

# Create a writable temporary directory for Swift compilation caches
export TMPDIR="${PWD}/tmp"
mkdir -p "$TMPDIR"

# Compile the Swift file, directing caches to TMPDIR
swiftc GemmaGUI.swift -o GemmaGUI

# Make the resulting binary executable (should already be)
chmod +x GemmaGUI

echo "✅ Build succeeded. You can now run ./GemmaGUI"
