# WORK IN PROGRESS !!!

# Claude Code Ultra YOLO Patcher

Disables ALL permission prompts in Claude Code for VSCode/Cursor.

## ⚠️ DISCLAIMER

**USE AT YOUR OWN RISK** - Bypasses ALL safety checks. Unofficial and unsupported.

## What It Does

Patches 3 files (`extension.js`, `cli.js`, `webview/index.js`) with 4 modifications:

1. **CLI Flag**: Adds `--dangerously-skip-permissions`
2. **Permission Bypass**: Auto-allows all permission requests + logging
3. **Deny→Allow**: Changes `behavior:"deny"` to `behavior:"allow"`
4. **Startup Logging**: Tracks when files are loaded

## Requirements

**Python 3.6+** (included with most systems)
- Windows: Python usually installed, or download from python.org
- Linux/WSL: `python3` pre-installed

## 🚀 Quick Start (RECOMMENDED)

### ✨ Pure Python Version - ONE SCRIPT for Windows & WSL!

```bash
# Windows (from PowerShell or Git Bash)
python ultra-yolo-patcher.py -y

# WSL (from Windows)
wsl python3 /mnt/c/path/to/ultra-yolo-patcher.py -y

# Or from within WSL
python3 ultra-yolo-patcher.py -y
```

**Commands:**
- `python ultra-yolo-patcher.py -y` - Apply patches (no prompts)
- `python ultra-yolo-patcher.py --undo -y` - Restore original files
- `python ultra-yolo-patcher.py --repatch -y` - Undo + patch (after updates)
- `python ultra-yolo-patcher.py` - Apply patches (with confirmation)

### 📋 Alternative: PowerShell/Bash Scripts (Legacy)

<details>
<summary>Click to expand PowerShell/Bash instructions</summary>

#### Windows (PowerShell)
```powershell
.\ultra-yolo-patcher.ps1           # Apply patches (Windows + WSL if detected)
.\ultra-yolo-patcher.ps1 -undo     # Restore original (Windows + WSL)
.\ultra-yolo-patcher.ps1 -repatch  # Undo + patch (Windows + WSL)
.\ultra-yolo-patcher.ps1 -yes      # Skip confirmations
.\ultra-yolo-patcher.ps1 -skipWsl  # Skip WSL patching (Windows only)
```

#### Linux/WSL (Bash)
```bash
chmod +x ultra-yolo-patcher.sh
./ultra-yolo-patcher.sh           # Apply patches
./ultra-yolo-patcher.sh -undo     # Restore original
./ultra-yolo-patcher.sh -repatch  # Undo + patch
./ultra-yolo-patcher.sh -yes      # Skip confirmations
```

</details>

**⚠️ RESTART VSCode/Cursor after patching or undoing!**

## Testing the Patch

After patching and restarting VSCode/Cursor, verify YOLO mode is working:

**Test with Docker Hello World:**
```bash
# Ask Claude Code to run:
docker run hello-world
```

If working correctly, Claude should execute **immediately without asking for permission**.

**Check the logs to confirm:**
```powershell
# Windows
Get-Content "$env:TEMP\claude-code-yolo.log" -Tail 20

# Linux/WSL
tail -20 /tmp/claude-code-yolo.log
```

You should see entries like:
```
[2025-10-11T15:37:37.799Z] YOLO FILE LOADED: extension.js
[2025-10-11T15:37:43.460Z] PERMISSION REQUEST - Tool: Bash | Inputs: {...} | AUTO-ALLOWED
```

## View Logs

**Windows:**
```powershell
Get-Content $env:TEMP\claude-code-yolo.log -Wait -Tail 20
```

**Linux/WSL:**
```bash
tail -f /tmp/claude-code-yolo.log
```

## Features

- ✅ **Pure Python** - Single script for Windows & WSL (no shell quoting hell!)
- ✅ Complete permission bypass
- ✅ Automatic file discovery (finds all Claude Code versions)
- ✅ Automatic backups (`.bak` files)
- ✅ Comprehensive logging (permission requests + file loads)
- ✅ Cross-platform (Windows + Linux/WSL + Mac)
- ✅ Fully reversible with `--undo`
- ✅ OS-specific log paths (Windows: `%TEMP%`, WSL: `/tmp`)

## Security Warning

With YOLO mode enabled, Claude can:
- Run ANY command without asking
- Modify ANY file without confirmation
- Execute system operations instantly

**Only use if you fully trust Claude and understand the risks.**

## Known Issues

### PowerShell Prompt Corruption (WSL Patching)

When running `ultra-yolo-patcher.ps1` on Windows with WSL patching enabled, the PowerShell prompt may appear corrupted after completion (cursor positioned incorrectly).

**Symptoms:**
- Prompt appears with extra spacing
- Text appears offset to the right
- Terminal still functions normally

**Workarounds:**
1. Close and reopen the PowerShell window

**Root Cause:** WSL Python output leaves the cursor in an incorrect position when piped through PowerShell. Multiple fixes attempted (console flushing, carriage returns, terminal resets) but the underlying WSL/PowerShell interaction issue persists.

## Example Output

    Windows PowerShell
    Copyright (C) Microsoft Corporation. All rights reserved.

    Install the latest PowerShell for new features and improvements! https://aka.ms/PSWindows

    PS C:\Users\jimmy> cd .\src\claude-code-extension-patchger\
    PS C:\Users\jimmy\src\claude-code-extension-patchger> .\ultra-yolo-patcher.ps1  -yes
    Claude Code YOLO Patcher - Dual Mode (Windows + WSL)

    [1/2] Windows...
    [FOUND] C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.10-universal (3 files)
    [FOUND] C:\Users\jimmy\.vscode\extensions\anthropic.claude-code-1.0.109 (1 files)
    Patched 4/4 files
    RESTART Cursor/VSCode!
    Logs: C:\Users\jimmy\AppData\Local\Temp\claude-code-yolo.log

    [2/2] WSL...
    [FOUND] /home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal (3 files)
    [FOUND] /home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.14-universal (3 files)
    Patched 6/6 files
    RESTART Cursor/VSCode!
    Logs: /tmp/claude-code-yolo.log
    PS C:\Users\jimmy\src\claude-code-extension-patchger>

## Credits

Based on: [GitHub Issue #8539](https://github.com/anthropics/claude-code/issues/8539#issuecomment-3389961296)
Created by: [@lifodetails](https://github.com/lifodetails)

## License

Provided as-is for educational purposes. **USE AT YOUR OWN RISK.**
