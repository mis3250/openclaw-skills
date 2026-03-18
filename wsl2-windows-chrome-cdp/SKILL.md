---
name: wsl2-windows-chrome-cdp
description: Comprehensive guide for configuring OpenClaw (running in WSL2) to connect to a Windows Chrome browser instance via CDP (Chrome DevTools Protocol). Use this skill when troubleshooting browser automation across the WSL2-Windows network boundary, specifically addressing "Connection Refused", "Ghost Chrome", or `netsh portproxy` bridging requirements.
---

# WSL2 to Windows Chrome CDP Configuration

When OpenClaw runs inside WSL2 and needs to control Chrome running on the Windows host using the `existing-session` driver, connecting can fail because Windows Chrome aggressively defaults to listening only on `127.0.0.1` (localhost), which is unreachable from the WSL2 virtual network.

This guide details the complete solution, including defeating background Chrome processes and setting up a Windows Port Proxy to bridge the gap.

## 1. Defeat "Ghost Chrome" (Background Apps)

Chrome often leaves background processes running even when all windows are closed, which prevents the debugging port from opening.

1. Open Chrome normally, go to `chrome://settings/system`.
2. Toggle **OFF** "Continue running background apps when Google Chrome is closed."
3. Close Chrome completely.
4. To be absolutely sure, open PowerShell and run: `Stop-Process -Name "chrome" -ErrorAction SilentlyContinue`

## 2. Launch Windows Chrome in Debug Mode

Launch Chrome with the debugging flags from the Windows Run prompt (Win+R) or PowerShell:

```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --remote-allow-origins="*" --remote-debugging-address=0.0.0.0 --user-data-dir="C:\temp\openclaw_profile"
```
*Note: Using a temporary `--user-data-dir` ensures no main-profile extensions or settings hijack the port.*

To verify it is listening, run in PowerShell:
```powershell
netstat -ano | findstr :9222
```
*Even with `--remote-debugging-address=0.0.0.0`, Windows 11 often forces it to `127.0.0.1:9222`. If you see `127.0.0.1:9222`, WSL cannot reach it directly, and you must proceed to Step 4.*

## 3. Find the Windows Host IP

From your WSL terminal, find the IP address of the Windows host:
```bash
ip route show | grep default | awk '{print $3}'
```
*(e.g., `172.27.160.1`)*

## 4. The Critical Fix: Windows Port Proxy

Because Chrome refuses to bind to `0.0.0.0` securely, we must tell Windows to forward traffic from the WSL network into the local loopback.

Open **PowerShell as Administrator** in Windows and run (replace `<WSL_HOST_IP>` with the IP found in Step 3):

```powershell
# Clear any stale proxies
netsh interface portproxy reset

# Bridge the WSL IP to localhost Chrome
netsh interface portproxy add v4tov4 listenport=9222 listenaddress=<WSL_HOST_IP> connectport=9222 connectaddress=127.0.0.1
```

## 5. Verification

From your WSL terminal, test the bridge:
```bash
curl -I http://<WSL_HOST_IP>:9222/json/version
```
If you receive `HTTP/1.1 200 OK`, the bridge is officially open.

## 6. Configure OpenClaw

Update your `openclaw.json` configuration file so OpenClaw knows where to point. Make sure to use the WSL Host IP, not localhost:

```json
{
  "browser": {
    "provider": "existing-session",
    "cdpUrl": "http://<WSL_HOST_IP>:9222",
    "attachOnly": true
  }
}
```

## Troubleshooting
- **Connection reset by peer (Error 56):** Chrome is actively rejecting the connection. Ensure you included the `--remote-allow-origins="*"` flag when launching Chrome.
- **Connection refused (Error 7):** The Windows Port Proxy is not working or Windows Firewall is blocking port 9222 on the vEthernet (WSL) network adapter.