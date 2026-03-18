#!/bin/bash

# Fast Gmail Sender for OpenClaw
# Usage: ./send.sh <to_email> <subject> <body>

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <to_email> <subject> <body>"
    exit 1
fi

TO=$1
SUBJECT=$2
BODY=$3

# URL encode the parameters
encode_url() {
    python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

ENC_TO=$(encode_url "$TO")
ENC_SUBJECT=$(encode_url "$SUBJECT")
ENC_BODY=$(encode_url "$BODY")

# The view=cm&fs=1 parameters force Gmail to open the fullscreen compose window
URL="https://mail.google.com/mail/u/0/?view=cm&fs=1&to=${ENC_TO}&su=${ENC_SUBJECT}&body=${ENC_BODY}"

echo ">> Navigating to Gmail compose window..."
# Use navigate so we stay in the same tab, preventing "ghost tabs" from piling up
openclaw browser navigate "$URL"

echo ">> Waiting for the compose window to load..."
# Wait for the "Send" button or the To field to be fully loaded
openclaw browser wait --timeout-ms 15000 "div[aria-label='Message Body']"

if [ $? -ne 0 ]; then
    echo "Error: Failed to load the compose window. Ensure you are logged into Gmail."
    exit 1
fi

echo ">> Dispatching email (Ctrl+Enter)..."
# Press Control+Enter to trigger the "Send" shortcut in Gmail
openclaw browser press "Control+Enter"

echo ">> Waiting for the email to send..."
# Optional: wait briefly for the 'Message sent' toast or just sleep to let the network request finish
sleep 2

echo "✅ Email sent successfully to $TO!"
