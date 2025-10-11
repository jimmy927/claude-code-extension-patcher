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

## Example Output

```
==========================================================
       Claude Code Ultra YOLO Patcher
       100% NO PERMISSION PROMPTS MODE
==========================================================

Searching for Claude Code extensions...

[FOUND] C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.10-universal\extension.js
[FOUND] C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.10-universal\resources\claude-code\cli.js
[FOUND] C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.10-universal\webview\index.js

[INFO] Found 3 extension(s)

This will modify the extension to NEVER ask for permissions.
ALL commands will be auto-approved. 100% YOLO MODE!

Press any key to continue, or close this window to cancel.

==========================================================
Processing: extension.js
==========================================================
[ACTION] Creating backup...
[SUCCESS] Backup created
[ACTION] Applying ULTRA YOLO patches...
  [PATCH 1] Adding --dangerously-skip-permissions flag
  [PATCH 2] Disabling permission prompts (auto-allow ALL)
  [PATCH 3] Changing deny behaviors to allow
  [PATCH 4] Adding startup logging

[ACTION] Writing patched file...
[SUCCESS] Ultra YOLO patches applied!

==========================================================
                   SUMMARY
==========================================================
Total extensions found: 3
Successfully patched:    3
Skipped:                 0
Errors:                  0
==========================================================

IMPORTANT: RESTART Cursor/VSCode completely to apply changes!

After restart, Claude Code will NEVER ask for permissions.

To undo: .\ultra-yolo-patcher.ps1 -undo
To repatch: .\ultra-yolo-patcher.ps1 -repatch

Press any key to exit...
```

## Credits

Based on: [GitHub Issue #8539](https://github.com/anthropics/claude-code/issues/8539#issuecomment-3389961296)
Created by: [@lifodetails](https://github.com/lifodetails)

## License

Provided as-is for educational purposes. **USE AT YOUR OWN RISK.**
