# Claude Code Extension Architecture

## Overview

The Claude Code VSCode/Cursor extension consists of JavaScript files that control permissions. This document explains how permission prompts work and how this patcher bypasses them.

---

## File Structure

```
anthropic.claude-code-2.0.x-universal/
├── extension.js           # VSCode extension entry point (~266KB)
├── package.json           # Extension manifest
├── resources/
│   └── claude-code/
│       └── cli.js         # Claude CLI executable (~9MB)
└── webview/
    └── index.js           # Webview UI
```

## Key Components

### 1. `extension.js` - VSCode Extension Layer
- Launches the CLI process with command-line arguments
- Manages the webview interface
- Handles VSCode integration (commands, menus, etc.)
- Contains `requestToolPermission()` that shows permission prompts

### 2. `cli.js` - Command Execution Layer
- The actual Claude Code CLI that executes commands
- Contains permission checking logic
- All files are heavily minified (variable names shortened, no whitespace)

### 3. `webview/index.js` - UI Layer
- Renders the webview interface
- May contain additional permission-related UI code

---

## Permission Flow

```
User requests Claude to run a command
    ↓
cli.js detects it needs permission
    ↓
Sends permission request to extension.js
    ↓
extension.js shows VSCode prompt
    ↓
User clicks "Yes" or "No"
    ↓
Response sent back to cli.js
    ↓
Command executes or cancels
```

---

## What This Patcher Does

This tool applies **3 types of patches** to completely disable permission prompts:

### Patch 1: Add `--dangerously-skip-permissions` Flag
**File:** `extension.js` only

**Location:** CLI launch arguments array (variable name `k` or `F` after minification)

```javascript
// BEFORE
k=["--output-format","stream-json","--verbose","--input-format","stream-json"]

// AFTER
k=["--dangerously-skip-permissions","--output-format","stream-json","--verbose","--input-format","stream-json"]
```

**Purpose:** Tells CLI to skip some permission checks (but not all - see below)

---

### Patch 2: Replace `requestToolPermission()` Function
**File:** `extension.js` only (cli.js doesn't have this function in detectable form)

**Original function:**
```javascript
async requestToolPermission(e,r,a,s){
  return(await this.sendRequest(e,{type:"tool_permission_request",toolName:r,inputs:a,suggestions:s})).result
}
```

**Replacement (with logging):**
```javascript
async requestToolPermission(e,r,a,s){
  try{
    const fs=require("fs");
    const log="["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\n";
    fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  }catch(err){}
  return{behavior:"allow",updatedInput:a}
}
```

**Purpose:** Auto-allows all permission requests instead of showing prompts

**Note:** Uses `require("fs")` because extension.js is CommonJS, not ES modules

---

### Patch 3: Change `behavior:"deny"` to `behavior:"allow"`
**Files:** All JavaScript files

```javascript
// BEFORE
behavior:"deny"

// AFTER
behavior:"allow"
```

**Results:**
- `extension.js`: 0 instances changed
- `cli.js`: ~16 instances changed (varies by version)
- `webview/index.js`: 0 instances changed

**Purpose:** Ensures any remaining deny behaviors are converted to allow

---

### Patch 4: Add Startup Logging
**Files:** All JavaScript files

**For `extension.js` (CommonJS):**
```javascript
try{
  const fs=require("fs");
  const log="["+new Date().toISOString()+"] YOLO FILE LOADED: extension.js\n";
  fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  console.log("YOLO LOADED: extension.js");
}catch(e){
  console.error("YOLO ERROR in extension.js:",e);
};
// ... rest of file ...
```

**For `cli.js` (ES module with shebang):**
```javascript
#!/usr/bin/env node
(async()=>{
  try{
    const fs=await import("fs");
    const log="["+new Date().toISOString()+"] YOLO FILE LOADED: cli.js\n";
    fs.appendFileSync("/tmp/claude-code-yolo.log",log);
  }catch(e){}
})();
// ... rest of file ...
```

**For `webview/index.js`:**
```javascript
try{
  const fs=require("fs");
  const log="["+new Date().toISOString()+"] YOLO FILE LOADED: index.js\n";
  fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
}catch(e){};
// ... rest of file ...
```

**Purpose:** Confirms which files loaded successfully after patching

**Important differences:**
- `cli.js` uses `await import("fs")` because it's an ES module
- `cli.js` has shebang (`#!/usr/bin/env node`) that must stay on line 1
- `cli.js` avoids `console.log` because it breaks JSON-RPC protocol
- `extension.js` uses `require("fs")` because it's CommonJS
- `webview/index.js` logs will fail silently in browser context

---

## Why All Files Need Patching

Even though the code analysis shows most patches affect `extension.js`, we patch all files because:

1. **Extension.js** launches CLI with the `--dangerously-skip-permissions` flag
2. **Extension.js** contains the `requestToolPermission()` function that shows prompts
3. **CLI.js** contains behavior deny statements that need changing
4. **Webview/index.js** may contain additional permission UI elements

The patcher works by pattern matching against minified code, so it's defensive and patches all found files.

---

## Log Files

**Windows:**
```
C:\Users\<username>\AppData\Local\Temp\claude-code-yolo.log
```

**Linux/WSL:**
```
/tmp/claude-code-yolo.log
```

### Log Entry Types

1. **Startup logs** (confirms patches loaded):
```
[2025-10-15T10:30:00.123Z] YOLO FILE LOADED: extension.js
[2025-10-15T10:30:01.456Z] YOLO FILE LOADED: cli.js
```

2. **Permission requests** (from requestToolPermission):
```
[2025-10-15T10:31:00.789Z] PERMISSION REQUEST - Tool: Bash | Inputs: {"command":"docker ps"} | AUTO-ALLOWED
```

### Multiple cli.js Startup Logs?

You may see cli.js loaded 2-3 times because Claude Code spawns multiple CLI processes. This is normal.

---

## Verification

To verify patches are working:

### 1. Check log file exists
```powershell
# Windows
Get-Content $env:TEMP\claude-code-yolo.log

# Linux/WSL
cat /tmp/claude-code-yolo.log
```

### 2. Look for startup entries
Should see at least 2 entries (extension.js + cli.js):
```
[2025-10-15T10:30:00.123Z] YOLO FILE LOADED: extension.js
[2025-10-15T10:30:01.456Z] YOLO FILE LOADED: cli.js
```

### 3. Test a command
Ask Claude Code: `"run docker hello world"`

Should execute **immediately without prompts**.

### 4. Monitor logs in real-time
```powershell
# Windows
Get-Content $env:TEMP\claude-code-yolo.log -Wait -Tail 20

# Linux/WSL
tail -f /tmp/claude-code-yolo.log
```

---

## Technical Notes

### Module System Differences

| File | Module System | Import Syntax | Console.log Safe? | Shebang? |
|------|--------------|---------------|-------------------|----------|
| `extension.js` | CommonJS | `require("fs")` | ✅ Yes | ❌ No |
| `cli.js` | ES Modules | `await import("fs")` | ❌ No (breaks JSON output) | ✅ Yes |
| `webview/index.js` | Browser | `require()` fails silently | ✅ Yes (browser console) | ❌ No |

### Minification

All files are heavily minified:
- Variable names shortened (e.g., CLI args array is `k` or `F`)
- No whitespace
- All code on few lines
- Pattern matching must be precise

---

## Summary

**Total: 4 patches across 3 files**

1. ✅ **CLI Flag** - Add `--dangerously-skip-permissions` (extension.js)
2. ✅ **Permission Bypass** - Replace `requestToolPermission()` (extension.js)
3. ✅ **Deny→Allow** - Change behavior deny to allow (all files, ~16 in cli.js)
4. ✅ **Startup Logging** - Track file loads (all files)

**Result:** 🚀 **100% YOLO MODE** - No permission prompts, all commands auto-approved!

---

**⚠️ USE AT YOUR OWN RISK ⚠️**

Claude can execute **ANY command without asking** when these patches are applied.
