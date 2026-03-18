---
name: gemini-summarizer
description: Navigate to a Google Gemini conversation URL and extract its content for analysis. Use this skill when the user provides a Gemini chat link and wants a summary or analysis of that specific interaction. It requires the OpenClaw browser to be authenticated with Google.
---

# Gemini Summarizer Skill

This skill allows OpenClaw to directly access and read your web-based Google Gemini conversations. It is useful for extracting troubleshooting steps, brainstorming results, or code snippets from prior Gemini sessions.

## Prerequisites

- The `openclaw browser` must be running and connected.
- The browser must be logged into the Google account that owns the conversation (unless it's a public share link).

## Usage

Run the fetcher script with the URL of the Gemini chat:

```bash
./scripts/fetch_chat.sh "https://gemini.google.com/app/..."
```

After the script runs, OpenClaw will receive a text snapshot of the page, which it can then summarize or use to answer specific questions.

## Workflow

1.  **URL Navigation**: The script uses `openclaw browser navigate` to go to the provided URL.
2.  **Wait for Load**: It waits for the `main` container of the Gemini UI to appear.
3.  **Snapshotting**: It captures an efficient snapshot of the DOM, preserving the text of the conversation.
4.  **AI Analysis**: OpenClaw then reads the snapshot and distills the key information as requested by the user.

## Troubleshooting

- **Login Wall**: If the script captures a "Sign in" page instead of the chat, the browser session has expired or is not logged in.
- **Dynamic Content**: Some parts of long Gemini chats might be lazily loaded. In those cases, manual scrolling or multiple snapshots may be required.
- **Private URLs**: Regular `/app/` URLs are private. Ensure you are providing the correct link for the current logged-in profile.