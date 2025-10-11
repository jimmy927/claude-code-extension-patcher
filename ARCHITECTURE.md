# Claude Code Extension Architecture

## Overview

This document describes the architecture of the Claude Code VSCode/Cursor extension and how permission prompts work.

---

## File Structure

The Claude Code extension consists of multiple components:

```
anthropic.claude-code-2.0.10-universal/
├── extension.js                      # VSCode extension entry point (266KB)
├── package.json                      # Extension manifest
├── resources/
│   └── claude-code/
│       └── cli.js                    # Claude CLI executable (9MB) ⚠️ MAIN FILE
└── webview/
    └── index.js                      # Webview UI
```

## Key Components

### 1. `extension.js` (VSCode Extension Layer)
- **Size**: 266KB (minified)
- **Purpose**: VSCode extension host integration
- **Entry Point**: Activated via `"onStartupFinished"` event
- **Main Exports**:
  - `activate` function (exports as `jZ` after minification)
  - `deactivate` function
- **Key Functions**:
  - Launches the CLI process
  - Manages webview
  - Handles VSCode integration (commands, menus, etc.)
  - **Contains permission request forwarding**: `requestToolPermission()`

### 2. `resources/claude-code/cli.js` (The Real Claude CLI)
- **Size**: 9MB (minified)
- **Purpose**: The actual Claude Code CLI that runs commands
- **THIS IS WHERE PERMISSION PROMPTS ORIGINATE** ⚠️
- **Key Features**:
  - Executes bash/shell commands
  - Handles Docker commands
  - Processes file operations
  - **Sends permission requests to extension.js**

### 3. Permission Flow

```
User Action (e.g., Docker command)
    ↓
cli.js detects dangerous operation
    ↓
cli.js sends tool_permission_request
    ↓
extension.js receives request via requestToolPermission()
    ↓
extension.js shows VSCode prompt to user
    ↓
User clicks "Yes" or "No"
    ↓
Response sent back to cli.js
    ↓
cli.js executes or cancels command
```

## How the `--dangerously-skip-permissions` Flag Works

### In `extension.js`

The flag is added to the CLI launch arguments:

```javascript
// BEFORE
k=["--output-format","stream-json","--verbose","--input-format","stream-json"]

// AFTER (with patch)
k=["--dangerously-skip-permissions","--output-format","stream-json","--verbose","--input-format","stream-json"]
```

This tells the CLI to skip permission checks.

### In `cli.js`

The CLI checks for this flag and modifies its behavior accordingly. However, **some commands still trigger permission requests** even with this flag enabled.

## Why You Still Get Permission Prompts

Even after adding `--dangerously-skip-permissions`, prompts still appear because:

1. **The flag only partially disables checks** - Some command types (especially Docker with environment variables) bypass the flag
2. **Multiple permission layers exist**:
   - CLI-level checks
   - Extension-level checks
   - VSCode-level checks

3. **The `requestToolPermission()` function in extension.js** is still called and still shows prompts

## The Ultra YOLO Solution

To **completely disable all permission prompts**, we need to patch **ALL THREE** JavaScript files with **FOUR comprehensive patches**:

### Files Patched
1. **`extension.js`** (266KB) - VSCode extension host
2. **`cli.js`** (9MB) - Claude Code CLI executable ⚠️ **THE MAIN FILE**
3. **`webview/index.js`** - Webview UI component

### Patches Applied

#### Patch 1: Add `--dangerously-skip-permissions` Flag (extension.js only)
```javascript
// BEFORE
k=["--output-format","stream-json","--verbose","--input-format","stream-json"]
// or
F=["--output-format","stream-json","--verbose","--input-format","stream-json"]

// AFTER
k=["--dangerously-skip-permissions","--output-format","stream-json",...]
// or
F=["--dangerously-skip-permissions","--output-format","stream-json",...]
```

#### Patch 2: Replace `requestToolPermission()` Function (extension.js + cli.js)
```javascript
// BEFORE (extension.js - CommonJS)
async requestToolPermission(e,r,a,s){
  return(await this.sendRequest(e,{type:"tool_permission_request",toolName:r,inputs:a,suggestions:s})).result
}

// AFTER (with logging - CommonJS for extension.js)
async requestToolPermission(e,r,a,s){
  try{
    const fs=require("fs");
    const log="["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\n";
    fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  }catch(err){}
  return{behavior:"allow"}
}

// AFTER (with logging - ES modules for cli.js)
async requestToolPermission(e,r,a,s){
  try{
    const fs=await import("fs");
    const log="["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\n";
    fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  }catch(err){}
  return{behavior:"allow"}
}
```

#### Patch 3: Change All `deny` to `allow` (all files)
```javascript
// BEFORE
behavior:"deny"

// AFTER
behavior:"allow"
```

Result: **16 instances** changed in cli.js, 0 in extension.js, 0 in webview/index.js

#### Patch 3b: Add Logging to Tool `checkPermissions()` Functions (cli.js only)

Patches **6 tool functions** (ListMcpResourcesTool, ReadMcpResourceTool, TodoWrite, etc.):

```javascript
// BEFORE
async checkPermissions(A){
  return{behavior:"allow",updatedInput:A}
}

// AFTER
async checkPermissions(A){
  try{
    const fs=await import("fs");
    const log="["+new Date().toISOString()+"] PERMISSION CHECK: "+this.name+" | Input: "+JSON.stringify(A)+"\n";
    fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  }catch(e){}
  return{behavior:"allow",updatedInput:A}
}
```

#### Patch 3c: Add Logging to `am()` Function (cli.js only)

The `am()` function is the **core permission checker** used by:
- Bash tool
- Edit tool
- Write tool
- Read tool
- Grep tool
- Glob tool

```javascript
// BEFORE
function am(A,B,Q){
  if(typeof A.getPath!=="function")return{behavior:"ask",...};
  // ... extensive permission checking logic ...
  return{behavior:"ask",...}
}

// AFTER (with fire-and-forget async logging)
function am(A,B,Q){
  (async()=>{
    try{
      const fs=await import("fs");
      const log="["+new Date().toISOString()+"] PERMISSION CHECK (am): "+A.name+" | Input: "+JSON.stringify(B)+"\n";
      fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
    }catch(e){}
  })();
  if(typeof A.getPath!=="function")return{behavior:"ask",...};
  // ... permission logic now always returns allow ...
}
```

**Important:** Uses async IIFE (Immediately Invoked Function Expression) with `await import("fs")` because cli.js is an ES module, not CommonJS.

#### Patch 4: Add Startup Logging (all files)

**For cli.js** (ES module with shebang - NO console.log):
```javascript
#!/usr/bin/env node
(async()=>{
  try{
    const fs=await import("fs");
    const log="["+new Date().toISOString()+"] YOLO FILE LOADED: cli.js\n";
    fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  }catch(e){}
})();
// ... rest of file ...
```

**For extension.js** (CommonJS - CAN use console.log):
```javascript
try{
  const fs=require("fs");
  const log="["+new Date().toISOString()+"] YOLO FILE LOADED: extension.js\n";
  fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
  console.log("YOLO LOADED: extension.js");
}catch(e){
  console.error("YOLO ERROR in extension.js:",e);
}
// ... rest of file ...
```

**For webview/index.js** (browser context - logs will fail silently):
```javascript
try{
  const fs=require("fs");
  const log="["+new Date().toISOString()+"] YOLO FILE LOADED: index.js\n";
  fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log",log);
}catch(e){}
// ... rest of file ...
```

## Package.json Configuration

The extension is configured via `package.json`:

```json
{
  "name": "claude-code",
  "version": "2.0.10",
  "main": "./extension.js",
  "activationEvents": ["onStartupFinished"],
  "contributes": {
    "commands": [...],
    "keybindings": [...]
  }
}
```

Key settings:
- **Entry point**: `./extension.js`
- **Activation**: Runs when VSCode finishes starting up
- **Commands**: Various Claude Code commands (open, execute, etc.)

## Logging

All patches write to **ONE log file**:

```
C:\Users\<username>\AppData\Local\Temp\claude-code-yolo.log
```

### Log Entry Types

1. **File startup logs** (verify patches loaded):
   ```
   [2025-10-11T09:37:52.165Z] YOLO FILE LOADED: extension.js
   [2025-10-11T09:38:03.010Z] YOLO FILE LOADED: cli.js
   [2025-10-11T09:38:03.477Z] YOLO FILE LOADED: cli.js
   ```

2. **Permission check logs** (from `am()` function - most common):
   ```
   [2025-10-11T10:15:23.456Z] PERMISSION CHECK (am): Bash | Input: {"command":"ls","description":"List files"}
   [2025-10-11T10:16:45.789Z] PERMISSION CHECK (am): Edit | Input: {"file_path":"C:/test.js",...}
   [2025-10-11T10:17:12.345Z] PERMISSION CHECK (am): Write | Input: {"file_path":"C:/new.js",...}
   ```

3. **Tool-level permission checks** (from individual tool `checkPermissions()`):
   ```
   [2025-10-11T10:18:00.123Z] PERMISSION CHECK: TodoWrite | Input: {"todos":[...]}
   [2025-10-11T10:19:30.456Z] PERMISSION CHECK: ListMcpResourcesTool | Input: {"server":"example"}
   ```

4. **High-level permission requests** (rarely logged, most are caught by `am()`):
   ```
   [2025-10-11T10:20:00.789Z] PERMISSION REQUEST - Tool: Bash | Inputs: {...} | AUTO-ALLOWED
   ```

### Why Multiple cli.js Startup Logs?

You'll see cli.js loaded 2-3 times because:
- Claude Code spawns multiple CLI processes
- Each process loads cli.js independently
- This is normal behavior

## Verification

To verify patches are working:

1. **Check the log file exists**:
   ```powershell
   Get-Content $env:TEMP\claude-code-yolo.log
   ```

2. **Look for startup entries** (should see at least 3 - one extension.js, 2+ cli.js):
   ```
   [2025-10-11T09:37:52.165Z] YOLO FILE LOADED: extension.js
   [2025-10-11T09:38:03.010Z] YOLO FILE LOADED: cli.js
   [2025-10-11T09:38:03.477Z] YOLO FILE LOADED: cli.js
   ```

3. **Try a command** - should execute without prompts and log:
   ```powershell
   # In Claude Code, type: ;run ls

   # Then check the log:
   Get-Content $env:TEMP\claude-code-yolo.log -Tail 5
   ```

   Expected output:
   ```
   [2025-10-11T10:15:23.456Z] PERMISSION CHECK (am): Bash | Input: {"command":"ls",...}
   ```

4. **Monitor logs in real-time**:
   ```powershell
   Get-Content $env:TEMP\claude-code-yolo.log -Wait -Tail 20
   ```

## Module System Differences

Critical understanding for patching:

| File | Module System | Import Syntax | Console.log Safe? | Shebang? |
|------|--------------|---------------|-------------------|----------|
| `extension.js` | CommonJS | `require("fs")` | ✅ Yes | ❌ No |
| `cli.js` | ES Modules | `await import("fs")` | ❌ No (breaks JSON output) | ✅ Yes (`#!/usr/bin/env node`) |
| `webview/index.js` | Browser/Mixed | `require()` (fails silently) | ✅ Yes (but to browser console) | ❌ No |

**Why this matters:**
- Using `require()` in cli.js will fail (ES module)
- Using `await import()` in extension.js won't work as well (CommonJS)
- console.log in cli.js breaks the JSON-RPC protocol
- The shebang in cli.js MUST be on line 1

## Technical Details

### Minification
All files are heavily minified:
- Variable names shortened (e.g., `activate` becomes `jZ`, CLI args array is `k` or `F`)
- No whitespace
- All code on single/few lines
- Makes manual analysis difficult

### Permission Request Protocol
The extension uses a JSON-RPC style protocol between extension.js and cli.js:
```javascript
{
  type: "tool_permission_request",
  toolName: "Bash",
  inputs: {...},
  suggestions: [...]
}
```

## Permission Check Layers

Claude Code has **THREE permission layers** (all must be bypassed):

### Layer 1: CLI Flag (`--dangerously-skip-permissions`)
- Added by Patch 1 to extension.js
- Tells cli.js to skip some checks
- **NOT SUFFICIENT ALONE** - many checks bypass this flag

### Layer 2: High-Level `requestToolPermission()`
- In both extension.js and cli.js
- Called for major operations
- Bypassed by Patch 2 (auto-return "allow")

### Layer 3: Low-Level Permission Functions
- **`am()` function** - File operation permissions (Bash, Edit, Write, Read, Grep, Glob)
  - Bypassed by Patch 3c (logging + always allow)
- **Tool `checkPermissions()`** - Individual tool checks (TodoWrite, MCP tools, etc.)
  - Bypassed by Patch 3b (logging + always allow)
- **Behavior checks** - `behavior:"deny"` throughout code
  - Bypassed by Patch 3 (change deny → allow)

## Why ALL THREE Files Need Patching

| File | Size | Purpose | Why Patch Needed |
|------|------|---------|------------------|
| `extension.js` | 266KB | VSCode integration | Launches CLI with flags, handles permission UI |
| `cli.js` | 9MB | Command execution | **THE MAIN FILE** - Actually runs commands, contains `am()` function and tool permission logic |
| `webview/index.js` | Small | Webview UI | May contain permission UI elements |

**If you only patch one or two files, permission prompts can still appear because all three can independently trigger checks!**

## Summary

The Claude Code extension has a **three-layer architecture**:

1. **Extension host** (`extension.js`) - VSCode integration layer
   - Launches CLI processes
   - Manages webview
   - Forwards permission requests
   - **Patched with**: Flag injection, permission bypass, deny→allow, logging

2. **CLI executable** (`cli.js`) - Command execution layer ⚠️ **THE CRITICAL FILE**
   - 9MB of minified code
   - Contains `am()` function (core permission checker)
   - Contains all tool definitions and their `checkPermissions()` functions
   - Executes all commands (Bash, Edit, Write, Read, Grep, Glob, etc.)
   - **Patched with**: Permission bypass, deny→allow (16 instances), tool logging (Patch 3b), `am()` logging (Patch 3c), startup logging

3. **Webview UI** (`webview/index.js`) - User interface layer
   - UI rendering in browser context
   - May contain permission UI elements
   - **Patched with**: Deny→allow, startup logging

### Patch Summary

**Total: 4 main patches across 3 files**

- ✅ **Patch 1**: CLI flag injection (extension.js only)
- ✅ **Patch 2**: High-level permission bypass (extension.js + cli.js)
- ✅ **Patch 3**: Deny→allow conversion (all files, 16 in cli.js)
- ✅ **Patch 3b**: Tool-level logging (cli.js only, 6 tools)
- ✅ **Patch 3c**: Core `am()` logging (cli.js only)
- ✅ **Patch 4**: Startup logging (all files)

**Result**:

🚀 **100% YOLO MODE** 🚀
- **NO permission prompts** - Ever!
- **ALL commands auto-approved** - Instantly!
- **Complete logging** - Track everything!
- **Full audit trail** - Know what Claude requests!

Claude can execute **ANY command without asking**! 🔥

---

**⚠️ USE AT YOUR OWN RISK ⚠️**
