# WORK IN PROGRESS !!!

# Claude Code Ultra YOLO Patcher

Disables ALL permission prompts in Claude Code for VSCode/Cursor.

## ⚠️ DISCLAIMER

**USE AT YOUR OWN RISK** - Bypasses ALL safety checks. Unofficial and unsupported.

## What It Does

Patches 3 files (`extension.js`, `cli.js`, `webview/index.js`) with 4 modifications:

1. **CLI Flag**: Adds `--dangerously-skip-permissions`
2. **Permission Bypass**: Auto-allows all permission requests
3. **Deny→Allow**: Changes `behavior:"deny"` to `behavior:"allow"`
4. **Logging**: Tracks all permissions to `%TEMP%\claude-code-yolo.log` (Windows) or `/tmp/claude-code-yolo.log` (Linux)

## Requirements

**Windows:** PowerShell + Claude Code extension
**Linux/WSL:** Bash + `perl` + Claude Code extension

## Usage

### Windows (with automatic WSL detection!)
```powershell
.\ultra-yolo-patcher.ps1           # Apply patches (Windows + WSL if detected)
.\ultra-yolo-patcher.ps1 -undo     # Restore original (Windows + WSL)
.\ultra-yolo-patcher.ps1 -repatch  # Undo + patch (Windows + WSL)
.\ultra-yolo-patcher.ps1 -yes      # Skip confirmations
.\ultra-yolo-patcher.ps1 -skipWsl  # Skip WSL patching (Windows only)
```

**Note:** The PowerShell script automatically detects WSL and patches both Windows and WSL installations!

### Linux/WSL
```bash
chmod +x ultra-yolo-patcher.sh
./ultra-yolo-patcher.sh           # Apply patches
./ultra-yolo-patcher.sh -undo     # Restore original
./ultra-yolo-patcher.sh -repatch  # Undo + patch
./ultra-yolo-patcher.sh -yes      # Skip confirmations
```

**RESTART VSCode/Cursor after patching or undoing!**

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

- ✅ Complete permission bypass
- ✅ **Automatic WSL detection & patching** (PowerShell script patches both!)
- ✅ Automatic backups (`.bak` files)
- ✅ Comprehensive logging
- ✅ Cross-platform (Windows + Linux/WSL)
- ✅ Reversible with `-undo`

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
