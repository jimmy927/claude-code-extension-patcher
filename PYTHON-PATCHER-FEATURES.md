# Python Patcher - Complete Feature List

## ✅ Full Feature Parity with Bash/PowerShell Scripts

The `ultra-yolo-patcher.py` now has **ALL** the features from the bash and PowerShell scripts!

### 🎯 Core Patches Applied

#### Patch 1: CLI Flag
- Adds `--dangerously-skip-permissions` to Claude CLI arguments
- Works for both v2.0.10 and v2.0.14+ versions
- Pattern: `k=["--output-format","stream-json"` or `F=["--output-format","stream-json"`

#### Patch 2: Permission Bypass + Logging ⭐
- Replaces `requestToolPermission()` to immediately return `{behavior:"allow"}`
- **WITH LOGGING**: Logs every permission request to a file
- Detects ES modules (cli.js) vs CommonJS (extension.js) automatically
- Uses `require("fs")` for CommonJS, `import("fs")` for ES modules

#### Patch 3: Deny → Allow
- Changes all `behavior:"deny"` to `behavior:"allow"`
- Ensures no hardcoded denials remain

#### Patch 4: Startup Logging 🆕
- Logs when each file is loaded
- Detects file type and adds appropriate logging:
  - **cli.js with shebang**: Inserts after `#!/usr/bin/env node` (NO console.log)
  - **ES modules**: Prepends async IIFE (NO console.log - breaks JSON output)
  - **CommonJS**: Prepends with console.log (safe for extension.js)

### 📁 OS-Specific Log Files

| Platform | Log File | View Command |
|----------|----------|--------------|
| **Windows** | `%TEMP%\claude-code-yolo.log` | `Get-Content "$env:TEMP\claude-code-yolo.log" -Wait -Tail 20` |
| **WSL/Linux** | `/tmp/claude-code-yolo.log` | `tail -f /tmp/claude-code-yolo.log` |

### 📊 What Gets Logged

1. **Startup Events**:
   ```
   [2025-10-11T14:30:00.000Z] YOLO FILE LOADED: extension.js
   [2025-10-11T14:30:00.100Z] YOLO FILE LOADED: cli.js
   ```

2. **Permission Requests**:
   ```
   [2025-10-11T14:30:05.000Z] PERMISSION REQUEST - Tool: Bash | Inputs: {"command":"ls -la"} | AUTO-ALLOWED
   [2025-10-11T14:30:10.000Z] PERMISSION REQUEST - Tool: Edit | Inputs: {"file_path":"/path/to/file"} | AUTO-ALLOWED
   ```

### 🚀 Usage

```bash
# Windows
python ultra-yolo-patcher.py -y

# WSL (run from Windows)
wsl python3 /mnt/c/Users/jimmy/src/claude-code-extension-patchger/ultra-yolo-patcher.py -y

# Or run from within WSL
python3 ultra-yolo-patcher.py -y
```

### 🔄 Other Commands

```bash
# Undo all patches
python ultra-yolo-patcher.py --undo -y

# Repatch (undo + patch - useful after Claude Code updates)
python ultra-yolo-patcher.py --repatch -y
```

### ✨ Advantages Over Bash/PowerShell

1. **✅ Single script** - Works on both Windows and WSL (no separate .sh/.ps1)
2. **✅ No shell quoting hell** - Pure Python, no bash/PowerShell escaping issues
3. **✅ Reliable string replacement** - No perl/sed regex failures
4. **✅ Cross-platform paths** - Uses `pathlib.Path` for automatic path handling
5. **✅ Better error handling** - Python exceptions vs shell errors
6. **✅ No dependencies** - Uses only Python stdlib (os, pathlib, shutil)

### 🎯 Files Patched

The script automatically finds and patches:
- `extension.js` - Main extension code (Patch 1, 2, 3, 4)
- `cli.js` - CLI code (Patch 3, 4)
- `webview/index.js` - Webview code (Patch 3, 4)

### ⚠️ Important Notes

1. **RESTART Cursor/VSCode completely** after patching!
2. Backups are created with `.bak` extension
3. Logging is **always enabled** (was optional in bash/PowerShell)
4. Log files help debug if something goes wrong
5. All patches are safe - wrapped in `try/catch` to prevent breaking the extension

### 🔍 Verification

Check if patches were applied:

**Windows:**
```powershell
# Check permission function (should show logging code)
Select-String -Path "C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-*\extension.js" -Pattern "PERMISSION REQUEST"

# Check startup logging
Select-String -Path "C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-*\extension.js" -Pattern "YOLO FILE LOADED"
```

**WSL:**
```bash
# Check permission function
grep "PERMISSION REQUEST" ~/.cursor-server/extensions/anthropic.claude-code-*/extension.js

# Check startup logging
grep "YOLO FILE LOADED" ~/.cursor-server/extensions/anthropic.claude-code-*/extension.js
```

### 🎉 Result

After patching and restarting:
- ✅ **NO** permission prompts for ANY tools (Bash, Edit, Write, etc.)
- ✅ All permission requests logged to file for debugging
- ✅ Extension loads normally with all features working
- ✅ Can undo anytime with `--undo` flag
