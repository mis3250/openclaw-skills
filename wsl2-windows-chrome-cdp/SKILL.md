---
name: wsl2-windows-chrome-cdp
description: Guide for configuring OpenClaw (running in WSL2) to connect to a Windows Chrome browser instance via CDP (Chrome DevTools Protocol). Use this skill when troubleshooting or setting up browser automation across the WSL2-Windows network boundary, specifically addressing connection refused or DevToolsActivePort issues.
---

# WSL2 to Windows Chrome CDP Configuration

When OpenClaw runs inside WSL2 and needs to control Chrome running on the Windows host using the `existing-session` driver (CDP), you must bridge the virtual network gap between WSL2 and Windows.

## 1. Launching Windows Chrome

By default, Chrome binds its debugging port only to `127.0.0.1` (localhost), which is unreachable from the WSL2 subnet. 

Windows Chrome **must** be completely closed (ensure no background Chrome processes remain) and re-launched from the Windows Run prompt (Win+R) or Command Prompt with the following flags:

```cmd
chrome.exe --remote-debugging-port=9222 --remote-allow-origins=* --remote-debugging-address=0.0.0.0
```

*Critical:* The `--remote-debugging-address=0.0.0.0` flag is what allows the port to be exposed to the WSL2 virtual network.

## 2. Configuring OpenClaw in WSL2

In your `openclaw.json` configuration file, the `cdpUrl` must point to the Windows host IP address from the perspective of WSL2, NOT `localhost` or `127.0.0.1`.

1. Find the Windows host IP inside WSL2 (e.g., by checking `/etc/resolv.conf` nameserver or using `ip route`). It usually looks like `172.2x.x.x`.
2. Update the browser configuration in `openclaw.json`:

```json
{
  "browser": {
    "provider": "existing-session",
    "cdpUrl": "http://<WSL2-host-IP>:9222"
  }
}
```

## Troubleshooting

- **Connection Refused:** Ensure Windows Firewall is not blocking port 9222 on the vEthernet (WSL) network adapter.
- **Still Cannot Connect:** Verify that you completely killed all existing Chrome processes before launching with the debugging flags. If a normal Chrome instance is already running, running the command will just open a new window in the existing process without enabling the debugging port.