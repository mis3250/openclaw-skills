#!/bin/bash

# Gemini Chat Fetcher for OpenClaw
# Usage: ./fetch_chat.sh <gemini_url>

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <gemini_url>"
    exit 1
fi

URL=$1

echo ">> Navigating to Gemini conversation..."
openclaw browser navigate "$URL"

echo ">> Waiting for chat content to load..."
# Wait for a common element in Gemini's chat interface
openclaw browser wait --timeout-ms 20000 "main"

if [ $? -ne 0 ]; then
    echo "Error: Failed to load Gemini chat. Ensure you are logged in and the URL is valid."
    exit 1
fi

echo ">> Capturing chat snapshot..."
# Take a snapshot of the conversation
openclaw browser snapshot --efficient

echo "✅ Snapshot captured. Please analyze the output above."
