---
name: gmail-sender
description: Quickly send emails via Gmail Web Interface (UI) without manual DOM navigation. Use this skill when the user asks to send an email. It relies on the OpenClaw browser being authenticated with Gmail.
---

# Gmail Sender Skill

This skill allows OpenClaw to quickly send emails using a direct Gmail compose URL (`view=cm&fs=1`) and keyboard shortcuts, bypassing the slow process of searching the DOM for buttons.

## Prerequisites

- The `openclaw browser` must be running and connected.
- The active Chrome profile must be authenticated with Gmail (`mail.google.com`).

## Usage

Use the included bash script to instantly compose and send an email:

```bash
./scripts/send.sh "recipient@example.com" "Email Subject" "The body of the email goes here."
```

### Script Execution Note
If executing the script fails due to permission errors, make sure it is executable (`chmod +x scripts/send.sh`) or call it explicitly using bash (`bash scripts/send.sh ...`).

## Under the Hood

The `send.sh` script does the following:
1. URL-encodes your parameters (To, Subject, Body).
2. Navigates the current browser tab directly to the full-screen compose window: `https://mail.google.com/mail/u/0/?view=cm&fs=1&to=...&su=...&body=...`
3. Waits for the DOM to load.
4. Uses `openclaw browser press "Control+Enter"` to trigger the native Gmail send shortcut. 

## Troubleshooting

- **Gateway timeout / connection refused:** Ensure OpenClaw is properly connected to the Chrome instance (check `openclaw browser status`).
- **Cannot find Message Body:** The browser might not be logged into a Google account, or the page took longer than 15 seconds to load.
- **Empty body sent:** Ensure you quote strings correctly in bash to prevent them from being truncated.