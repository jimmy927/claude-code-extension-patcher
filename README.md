# Claude Code Ultra YOLO Patcher

Disables ALL permission prompts in Claude Code for VSCode/Cursor.

**Tested with Claude Code Extension versions:** 2.0.10, 2.0.14, 2.0.15

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
- Linux/macOS/WSL: `python3` pre-installed

> **⚠️ Testing Status:** This tool has **ONLY** been tested on **Windows with Cursor**. It should work with VSCode and on macOS/Linux, but this is untested. Use on other platforms at your own risk. **PRs welcome** to improve cross-platform support!

## 🚀 Quick Start

### Windows (RECOMMENDED: PowerShell Wrapper)

**Use the PowerShell wrapper to patch both Windows AND WSL automatically:**

```powershell
.\ultra-yolo-patcher.ps1 -yes      # Patch Windows + WSL (skip confirmations)
.\ultra-yolo-patcher.ps1 -undo -yes    # Restore originals
.\ultra-yolo-patcher.ps1 -repatch -yes # Undo + patch (after updates)
.\ultra-yolo-patcher.ps1 -skipWsl  # Patch Windows only
```

The PowerShell wrapper is tested on Windows with Cursor and handles both native Windows and WSL installations automatically.

### Linux / macOS / WSL (Python Script)

**Run the Python script directly (UNTESTED):**

```bash
python3 ultra-yolo-patcher.py -y       # Apply patches (no prompts)
python3 ultra-yolo-patcher.py --undo -y    # Restore original files
python3 ultra-yolo-patcher.py --repatch -y # Undo + patch (after updates)
```

> **Note:** Not tested on macOS/Linux. Should work in theory, but backup your files first! **PRs welcome** for testing/fixes on other platforms.

### 📋 Windows Alternative: Direct Python

<details>
<summary>Click to expand alternative Windows method</summary>

#### Windows Direct Python (without PowerShell wrapper)
```bash
# Run Python script directly
python ultra-yolo-patcher.py -y
python ultra-yolo-patcher.py --undo -y
python ultra-yolo-patcher.py --repatch -y
```

</details>

**⚠️ RESTART VSCode/Cursor after patching or undoing!**

## Testing the Patch

After patching and restarting VSCode/Cursor, verify YOLO mode is working:

**Test with Docker Hello World:**

Ask Claude Code: `"run docker hello world for me and tell me if it worked"`

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
