#!/bin/bash

# PPTAgent Installer for OpenClaw
# This script ensures uv is installed and attempts a first-time check of pptagent.

echo ">> Checking for 'uv'..."
if ! command -v uv &> /dev/null; then
    echo ">> Installing 'uv'..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.cargo/env
fi

echo ">> Testing 'pptagent' via uvx..."
# Note: We use a specific python version to avoid build issues on experimental versions
uvx --python 3.12 pptagent --version

if [ $? -eq 0 ]; then
    echo "✅ PPTAgent is ready!"
    echo ">> Next step: Run 'uvx pptagent onboard' in your terminal to set up API keys."
else
    echo "❌ Build failed. Please ensure you have python3-dev and g++ installed."
    echo "On Ubuntu/WSL: sudo apt update && sudo apt install python3-dev build-essential"
fi
