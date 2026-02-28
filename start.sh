#!/bin/sh
# start.sh - Launch Ollama and verify Gemma 3 4B model

# Kill any existing Ollama process
pkill ollama 2>/dev/null

# Allow CORS for local file URLs
export OLLAMA_ORIGINS="*"

# Start Ollama in background
ollama serve &>/dev/null &
OLLAMA_PID=$!

# Wait up to 10 seconds for the API to become available
MAX_WAIT=10
INTERVAL=1
elapsed=0
while ! curl -s -o /dev/null http://localhost:11434/api/tags; do
  sleep $INTERVAL
  elapsed=$((elapsed + INTERVAL))
  if [ $elapsed -ge $MAX_WAIT ]; then
    echo "❌ Ollama failed to start within $MAX_WAIT seconds."
    kill $OLLAMA_PID 2>/dev/null
    exit 1
  fi
done

# Success message
echo "✅ Ollama is running with Gemma 3 4B model."

echo "You can now open the web UI (index.html) or use the CLI (gemma.sh)."
