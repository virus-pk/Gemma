#!/bin/sh
# gemma.sh - CLI wrapper for Gemma 3 4B model via Ollama

MODEL="gemma3:4b"
API_URL="http://localhost:11434/api/generate"

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 \"prompt\""
  exit 1
fi

PROMPT="$1"

echo "--- Thinking ---"

# Use curl to stream response, parse each line as JSON and extract the 'response' field
curl -s -N -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "{\"model\": \"$MODEL\", \"prompt\": \"$PROMPT\", \"stream\": true}" |
while IFS= read -r line; do
  # Extract response field using sed (simple JSON parsing, assumes no escaped quotes in response)
  resp=$(echo "$line" | sed -n 's/.*"response":"\([^"}]*\)".*/\1/p')
  if [ -n "$resp" ]; then
    # Decode escaped characters (\n and \"")
    printf "%b" "${resp//\\n/\n}" | tr -d '\\"'
  fi
done

echo "\n--- Done ---"
