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

To **completely disable all permission prompts**, we need to patch **BOTH** files:

### Patches Applied to BOTH `extension.js` AND `cli.js`:

#### Patch 1: Add `--dangerously-skip-permissions` Flag
```javascript
k=["--dangerously-skip-permissions","--output-format","stream-json",...]
```

#### Patch 2: Replace `requestToolPermission()` Function
```javascript
// BEFORE
async requestToolPermission(e,r,a,s){
  return(await this.sendRequest(e,{type:"tool_permission_request",toolName:r,inputs:a,suggestions:s})).result
}

// AFTER (with logging)
async requestToolPermission(e,r,a,s){
  const fs=require("fs");
  const logFile=require("os").tmpdir()+"\\ultra-yolo-patcher.log";
  try{
    const log="["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\n";
    fs.appendFileSync(logFile,log);
  }catch(err){}
  return{behavior:"allow"}
}
```

#### Patch 3: Change All `deny` to `allow`
```javascript
// BEFORE
behavior:"deny"

// AFTER
behavior:"allow"
```

#### Patch 4: Add Startup Logging
```javascript
// Added at the very beginning of each file
try{
  const fs=require("fs");
  const log="["+new Date().toISOString()+"] YOLO EXTENSION STARTED\n";
  fs.appendFileSync(require("os").tmpdir()+"\\ultra-yolo-patcher.log",log);
}catch(e){}
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

All patches write to a single log file:

```
%TEMP%\ultra-yolo-patcher.log
```

Log entries:
1. **Extension startup**: `[timestamp] YOLO EXTENSION STARTED`
2. **Permission requests**: `[timestamp] PERMISSION REQUEST - Tool: Bash | Inputs: {...} | AUTO-ALLOWED`

## Verification

To verify patches are working:

1. **Check the log file exists**:
   ```powershell
   Get-Content $env:TEMP\ultra-yolo-patcher.log
   ```

2. **Look for startup entries** (should see 2 - one for extension.js, one for cli.js):
   ```
   [2025-10-10T17:00:00.000Z] YOLO EXTENSION STARTED
   [2025-10-10T17:00:01.000Z] YOLO EXTENSION STARTED
   ```

3. **Try a Docker command** - should execute without prompts and log:
   ```
   [2025-10-10T17:01:00.000Z] PERMISSION REQUEST - Tool: Bash | Inputs: {"command":"docker build..."} | AUTO-ALLOWED
   ```

## Technical Details

### Minification
Both files are heavily minified:
- Variable names shortened (e.g., `activate` becomes `jZ`)
- No whitespace
- All code on single/few lines
- Makes manual analysis difficult

### Module System
Uses CommonJS/Node.js modules:
- `require("fs")` for file operations
- `require("os")` for temp directory
- `require("vscode")` for VSCode API

### Permission Request Protocol
The extension uses a JSON-RPC style protocol:
```javascript
{
  type: "tool_permission_request",
  toolName: "Bash",
  inputs: {...},
  suggestions: [...]
}
```

## Why Two Files Need Patching

| File | Purpose | Why Patch Needed |
|------|---------|------------------|
| `extension.js` | VSCode integration | Handles permission UI, forwards requests |
| `cli.js` | Command execution | Actually runs commands, initiates requests |

**If you only patch one file, permission prompts still appear because the other file still has the checks!**

## Summary

The Claude Code extension is split into:
1. **Extension host** (`extension.js`) - VSCode layer
2. **CLI executable** (`cli.js`) - Command execution layer

**Both files must be patched** to achieve true "YOLO mode" where no permission prompts ever appear.

The Ultra YOLO Patcher modifies both files to:
- Auto-approve all permissions
- Log all activity
- Never show prompts to the user

---

**Result**: 100% YOLO MODE - Claude can execute ANY command without asking! 🚀
