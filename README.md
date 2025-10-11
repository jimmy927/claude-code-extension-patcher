# Claude Code Ultra YOLO Patcher

**🚀 100% NO PERMISSION PROMPTS MODE - NEVER ASK FOR ANYTHING! 🚀**

A Windows PowerShell script that **completely disables ALL permission prompts** in the Claude Code VSCode/Cursor extension.

## ⚠️ ULTRA DISCLAIMER ⚠️

**EXTREME USE AT YOUR OWN RISK**

This script makes **AGGRESSIVE modifications** to Claude Code extension files. By using this Ultra YOLO patcher:

- **NO WARRANTY**: Provided "as is" - things might break!
- **NO LIABILITY**: You're on your own if something goes wrong
- **SECURITY RISK**: This bypasses ALL safety checks - Claude can do ANYTHING
- **NO OFFICIAL SUPPORT**: Completely unofficial and unsupported
- **YOUR RESPONSIBILITY**: You accept full responsibility for ALL consequences

**This is the nuclear option. Only use if you know what you're doing.**

---

## What This Script Does

The **Ultra YOLO Patcher** applies **FOUR comprehensive patches** to **THREE JavaScript files**:

### Files Patched
- ✅ `extension.js` - VSCode extension host (266KB)
- ✅ `cli.js` - Claude Code CLI executable (9MB) - **THE MAIN FILE**
- ✅ `webview/index.js` - Webview UI component

### Patch 1: CLI Flag Injection
Adds `--dangerously-skip-permissions` to the CLI launch arguments:

```javascript
// Before
k=["--output-format","stream-json","--verbose","--input-format","stream-json"]

// After
k=["--dangerously-skip-permissions","--output-format","stream-json","--verbose","--input-format","stream-json"]
```

### Patch 2: Permission Function Bypass
Replaces the `requestToolPermission` function to auto-allow with logging:

```javascript
// Before
async requestToolPermission(e,r,a,s){
  return(await this.sendRequest(e,{type:"tool_permission_request",toolName:r,inputs:a,suggestions:s})).result
}

// After (with logging to track what permissions are requested)
async requestToolPermission(e,r,a,s){
  try{
    const fs=await import("fs");
    const log="["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\n";
    fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  }catch(err){}
  return{behavior:"allow"}
}
```

### Patch 3: Deny → Allow Conversion
Changes all `behavior:"deny"` to `behavior:"allow"` throughout all files (16 instances in cli.js).

### Patch 3b: Tool-Level Permission Logging
Adds logging to individual tool `checkPermissions()` functions:

```javascript
// Before
async checkPermissions(A){
  return{behavior:"allow",updatedInput:A}
}

// After (6 tools patched: ListMcp, ReadMcp, TodoWrite, etc.)
async checkPermissions(A){
  try{
    const fs=await import("fs");
    const log="["+new Date().toISOString()+"] PERMISSION CHECK: "+this.name+" | Input: "+JSON.stringify(A)+"\n";
    fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  }catch(e){}
  return{behavior:"allow",updatedInput:A}
}
```

### Patch 3c: Core Permission Function Logging
Adds logging to the `am()` function (used by Bash, Edit, Write, Read, Grep, Glob):

```javascript
// Before
function am(A,B,Q){
  if(typeof A.getPath!=="function")return{behavior:"ask",...};
  // ... permission logic ...
}

// After (with fire-and-forget async logging)
function am(A,B,Q){
  (async()=>{
    try{
      const fs=await import("fs");
      const log="["+new Date().toISOString()+"] PERMISSION CHECK (am): "+A.name+" | Input: "+JSON.stringify(B)+"\n";
      fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
    }catch(e){}
  })();
  if(typeof A.getPath!=="function")return{behavior:"ask",...};
  // ... permission logic (now always returns allow) ...
}
```

### Patch 4: Startup Logging
Adds logging when each file loads to verify patches are active:

```javascript
// For cli.js (ES module with shebang)
(async()=>{
  try{
    const fs=await import("fs");
    const log="["+new Date().toISOString()+"] YOLO FILE LOADED: cli.js\n";
    fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  }catch(e){}
})();

// For extension.js (CommonJS)
try{
  const fs=require("fs");
  const log="["+new Date().toISOString()+"] YOLO FILE LOADED: extension.js\n";
  fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  console.log("YOLO LOADED: extension.js");
}catch(e){
  console.error("YOLO ERROR in extension.js:",e);
}
```

**Result:** Claude Code will **NEVER** show a permission prompt. ALL commands are auto-approved instantly. All permission requests are logged for auditing. 🔥

## Features

- 🎯 **Complete Permission Bypass**: Never see another prompt
- 📝 **Comprehensive Logging**: Tracks all permission requests to one log file
- 🔍 **Auto-Detection**: Finds ALL `.js` files in Claude Code extensions (VSCode and Cursor)
- 💾 **Automatic Backups**: Creates `.bak` files before patching
- ↩️ **Reversible**: Use `-undo` to restore original behavior
- 🔄 **Repatch Mode**: Use `-repatch` to undo + patch in one command
- 📊 **Detailed Reports**: Clear status for each patch applied
- 🛡️ **Safe Restoration**: Undo mode restores from backups
- ⚡ **ES Module Compatible**: Handles both CommonJS and ES module files correctly

## Requirements

### Windows
- PowerShell
- Claude Code extension installed in VSCode and/or Cursor
- Administrator privileges (recommended)

### Linux / WSL
- Bash shell
- Claude Code extension installed in VSCode and/or Cursor
- `perl` command (usually pre-installed)

## Usage

### Windows

#### 🔥 Apply Ultra YOLO Mode

```powershell
.\ultra-yolo-patcher.ps1
```

Or double-click `ultra-yolo-patcher.ps1`

**IMPORTANT: Restart Cursor/VSCode completely after patching!**

#### ↩️ Restore Normal Behavior

```powershell
.\ultra-yolo-patcher.ps1 -undo
```

**IMPORTANT: Restart Cursor/VSCode completely after undoing!**

#### 🔄 Repatch (Undo + Patch)

```powershell
.\ultra-yolo-patcher.ps1 -repatch
```

Useful when updating Claude Code or re-applying patches.

#### 🚀 Silent Mode (No Prompts)

```powershell
.\ultra-yolo-patcher.ps1 -yes
```

Skips all confirmation prompts - useful for automation.

### Linux / WSL

#### 🔥 Apply Ultra YOLO Mode

```bash
chmod +x ultra-yolo-patcher.sh
./ultra-yolo-patcher.sh
```

**IMPORTANT: Restart Cursor/VSCode completely after patching!**

#### ↩️ Restore Normal Behavior

```bash
./ultra-yolo-patcher.sh -undo
```

**IMPORTANT: Restart Cursor/VSCode completely after undoing!**

#### 🔄 Repatch (Undo + Patch)

```bash
./ultra-yolo-patcher.sh -repatch
```

Useful when updating Claude Code or re-applying patches.

#### 🚀 Silent Mode (No Prompts)

```bash
./ultra-yolo-patcher.sh -yes
```

Skips all confirmation prompts - useful for automation.

## How It Works

### Patch Mode (Default)
1. Searches for **ALL `.js` files** in Claude Code extensions (VSCode and Cursor)
2. Creates backup (`.bak`) of each file before modification
3. Applies patches to each file:
   - **Patch 1**: Adds `--dangerously-skip-permissions` flag (extension.js only)
   - **Patch 2**: Replaces `requestToolPermission` function with auto-allow + logging
   - **Patch 3**: Changes all `behavior:"deny"` to `behavior:"allow"`
   - **Patch 3b**: Adds logging to tool `checkPermissions()` functions (cli.js only)
   - **Patch 3c**: Adds logging to `am()` permission function (cli.js only)
   - **Patch 4**: Adds startup logging to verify patches loaded
4. Reports results for each file

**Files Patched:**
- `extension.js` - Gets Patch 1, 2, 3, 4
- `cli.js` - Gets Patch 2, 3, 3b, 3c, 4 (the main file with most changes)
- `webview/index.js` - Gets Patch 3, 4 (minimal changes)

### Undo Mode (`-undo`)
1. Finds all Claude Code extension `.js` files
2. Restores each from `.bak` backup
3. Reports results

### Repatch Mode (`-repatch`)
1. Runs undo first
2. Then runs patch
3. Useful after Claude Code updates

## Logging

All patches write permission requests to **ONE log file**:

**Windows:**
```
C:\Users\<username>\AppData\Local\Temp\claude-code-yolo.log
```

**Linux/WSL:**
```
/tmp/claude-code-yolo.log
```

### Log Contents

**Startup logs** (verify patches loaded):
```
[2025-10-11T09:37:52.165Z] YOLO FILE LOADED: extension.js
[2025-10-11T09:38:03.010Z] YOLO FILE LOADED: cli.js
[2025-10-11T09:38:03.477Z] YOLO FILE LOADED: cli.js
```

**Permission request logs** (track what Claude asks for):
```
[2025-10-11T10:15:23.456Z] PERMISSION CHECK (am): Bash | Input: {"command":"ls","description":"List files"}
[2025-10-11T10:16:45.789Z] PERMISSION CHECK (am): Edit | Input: {"file_path":"C:/test.js","old_string":"...","new_string":"..."}
```

### View Logs

**Windows (PowerShell):**
```powershell
# View entire log
Get-Content $env:TEMP\claude-code-yolo.log

# Tail logs in real-time
Get-Content $env:TEMP\claude-code-yolo.log -Wait -Tail 20
```

**Linux/WSL (Bash):**
```bash
# View entire log
cat /tmp/claude-code-yolo.log

# Tail logs in real-time
tail -f /tmp/claude-code-yolo.log
```

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
Processing: C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.10-universal\extension.js
==========================================================
[ACTION] Creating backup...
[SUCCESS] Backup created
[ACTION] Applying ULTRA YOLO patches...
  [PATCH 1] Adding --dangerously-skip-permissions flag
  [PATCH 2] Disabling permission prompts (auto-allow ALL) + ONE LOG FILE
  [PATCH 3] Changing deny behaviors to allow
  [PATCH 4] Adding startup logging to ONE LOG FILE

[ACTION] Writing patched file...
[SUCCESS] Ultra YOLO patches applied!

==========================================================
Processing: C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.10-universal\resources\claude-code\cli.js
==========================================================
[ACTION] Creating backup...
[SUCCESS] Backup created
[ACTION] Applying ULTRA YOLO patches...
  [PATCH 1] Already applied or different version
  [PATCH 2] Pattern not found or already applied
  [PATCH 3] Changing deny behaviors to allow
  [PATCH 3b] Adding permission logging to checkPermissions functions
  [PATCH 3c] Adding permission logging to am() function (Bash, Edit, Write)
  [PATCH 4] Adding startup logging to ONE LOG FILE

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

IMPORTANT: RESTART Cursor completely to apply changes!

After restart, Claude Code will NEVER ask for permissions.

ALL LOGS written to ONE FILE:
  C:\Users\jimmy\AppData\Local\Temp\claude-code-yolo.log

To undo: .\ultra-yolo-patcher.ps1 -undo
To repatch: .\ultra-yolo-patcher.ps1 -repatch

Press any key to exit...
```

## Troubleshooting

**"Extension not found"**
- Verify Claude Code is installed
- Check you have access to extension directories

**"Pattern not found"**
- Extension may be a different version
- Try running with `-undo` first, then update Claude Code

**"Already YOLO?"**
- Already patched! No changes needed

**Permission Errors**
- Run PowerShell as Administrator
- Check file permissions

## Security Considerations

⚠️ **THIS IS THE NUCLEAR OPTION** ⚠️

With Ultra YOLO mode enabled:
- Claude can run ANY command without asking
- Docker commands execute immediately
- File modifications happen instantly
- System commands run without confirmation

**Only use this if:**
- You fully trust Claude
- You understand the risks
- You're working in a safe environment
- You accept full responsibility

## Original Work

Based on the original patcher concept from: [GitHub Issue](https://github.com/anthropics/claude-code/issues/8539#issuecomment-3389961296)

Created by: [@lifodetails](https://github.com/lifodetails)

Ultra YOLO enhancements: More aggressive permission bypassing

## License

Provided as-is for educational purposes. **USE AT YOUR OWN RISK.**

---

**Remember: With great power comes great responsibility. You've been warned! 🚀**
