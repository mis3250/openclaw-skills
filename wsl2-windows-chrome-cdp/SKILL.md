---
name: wsl2-windows-chrome-cdp
description: Comprehensive guide for configuring OpenClaw (running in WSL2) to connect to a Windows Chrome browser instance via CDP (Chrome DevTools Protocol). Use this skill when troubleshooting or setting up cross-environment browser automation, specifically addressing "connection refused" errors, DevToolsActivePort issues, WSL2 networking quirks, and Windows Firewall configurations.
---

# WSL2 to Windows Chrome CDP Configuration Guide

When OpenClaw runs inside WSL2 and needs to control Chrome running on the Windows host using the `existing-session` driver (CDP), you are crossing a virtual network boundary (NAT). By default, Chrome's debugging port only listens on `localhost` (127.0.0.1), making it completely invisible to WSL2.

This guide details the exact steps to bridge this gap, verify the connection, and troubleshoot common pitfalls.

## 1. Identify the Windows Host IP from WSL2

WSL2 runs on its own virtual subnet. You cannot use `localhost` or `127.0.0.1` inside `openclaw.json` because that points back to the WSL2 Linux instance itself.

**To find the host IP, run this in your WSL2 terminal:**
```bash
ip route show | grep -i default | awk '{ print $3}'
```
*(Alternatively, check the `nameserver` entry in `/etc/resolv.conf`).*

Note this IP (e.g., `172.27.160.1`). You will need it later.

## 2. Launch Windows Chrome (The Critical Step)

Before proceeding, **ensure every single instance of Chrome is closed on Windows**. Check the system tray (bottom right) and kill any background Chrome tasks, or run this in Windows Command Prompt:
```cmd
taskkill /F /IM chrome.exe
```

Launch Chrome from the Windows Run prompt (`Win + R`) or Command Prompt using the following exact parameters:

```cmd
chrome.exe --remote-debugging-port=9222 --remote-allow-origins=* --remote-debugging-address=0.0.0.0
```

### Why these flags?
* `--remote-debugging-port=9222`: Opens the CDP port.
* `--remote-allow-origins=*`: Bypasses CORS/origin checks. Without this, OpenClaw's websocket connection requests from a different IP will be rejected by Chrome.
* `--remote-debugging-address=0.0.0.0`: **The most important flag.** It forces Chrome to listen on ALL network interfaces (including the virtual WSL switch) instead of just `127.0.0.1`.

## 3. Verify the Connection

Before configuring OpenClaw, prove that the connection works.

**From Windows (Host):**
Open a browser and navigate to `http://localhost:9222/json/version`. You should see JSON output describing the Chrome version.

**From WSL2 (Guest):**
Run a curl command to the IP you found in Step 1:
```bash
curl -s http://<WSL2-host-IP>:9222/json/version
```
If you get a JSON response, the bridge is successfully established! If it hangs or says `Connection refused`, proceed to the Firewall Troubleshooting section.

## 4. Configure OpenClaw

Update your OpenClaw configuration file (`openclaw.json`) to use the host IP. 

```json
{
  "browser": {
    "provider": "existing-session",
    "cdpUrl": "http://<WSL2-host-IP>:9222"
  }
}
```

## 5. Troubleshooting & Firewall Setup

If the `curl` test in WSL2 fails, the Windows Defender Firewall is almost certainly blocking inbound connections on port 9222 from the WSL2 subnet.

### Add a Firewall Rule in Windows:
1. Open **Windows Defender Firewall with Advanced Security**.
2. Click **Inbound Rules** -> **New Rule...**
3. Rule Type: **Port** -> Next.
4. Protocol and Ports: **TCP**, Specific local ports: **9222** -> Next.
5. Action: **Allow the connection** -> Next.
6. Profile: Check all (Domain, Private, Public) -> Next.
7. Name: `Chrome CDP Debugging (WSL2)` -> Finish.

### Double-check Listening Ports:
If it still fails, confirm Chrome actually bound to `0.0.0.0`. Run this in Windows Command Prompt:
```cmd
netstat -ano | findstr 9222
```
You should see: `TCP    0.0.0.0:9222           0.0.0.0:0              LISTENING`
If you see `127.0.0.1:9222`, a ghost Chrome process was still running when you tried to launch it with the flags. Kill all Chrome processes and try again.