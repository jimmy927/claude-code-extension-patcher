# Claude Code Extension 2.0.22

## Changes from 2.0.21

This version introduced breaking changes to the minified code that required updates to the patcher:

### 1. CLI Arguments Variable Name Changed
- **Previous versions (2.0.21)**: `k` or `F`
- **Version 2.0.22**: `I`

**Pattern:**
```javascript
I=["--output-format","stream-json"
```

**Patch Applied:**
```javascript
I=["--dangerously-skip-permissions","--output-format","stream-json"
```

### 2. requestToolPermission Function Parameter Order Changed
- **Previous versions (2.0.21)**: `(e,r,a,s)` where inputs=a, suggestions=s
- **Version 2.0.22**: `(e,r,s,a)` where inputs=s, suggestions=a

**Original Function:**
```javascript
async requestToolPermission(e,r,s,a){return(await this.sendRequest(e,{type:"tool_permission_request",toolName:r,inputs:s,suggestions:a})).result}
```

**Replacement Function:**
```javascript
async requestToolPermission(e,r,s,a){try{const fs=require("fs");fs.appendFileSync("C:/Users/jimmy/AppData/Local/Temp/claude-code-yolo.log","["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(s)+" | AUTO-ALLOWED\n");}catch(err){}return{behavior:"allow",updatedInput:s}}
```

## Files Archived

- `extension.js` - Main extension file (923,402 bytes)
- `cli.js` - CLI interface file (9,734,140 bytes)
- `index.js` - Webview index file (4,382,134 bytes)

## Patcher Updates Required

The `ultra-yolo-patcher.py` was updated to:
1. Support the new variable name `I` for CLI args
2. Handle both old and new parameter orders for `requestToolPermission`
3. Maintain backward compatibility with older versions

## Date Archived
2025-10-18
