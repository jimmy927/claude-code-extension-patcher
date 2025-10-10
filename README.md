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

The **Ultra YOLO Patcher** makes **THREE critical modifications**:

### 1. CLI Flag Injection
Adds `--dangerously-skip-permissions` to the CLI launch arguments:

```javascript
// Before
k=["--output-format","stream-json","--verbose","--input-format","stream-json"]

// After
k=["--dangerously-skip-permissions","--output-format","stream-json","--verbose","--input-format","stream-json"]
```

### 2. Permission Function Bypass
Replaces the `requestToolPermission` function to always return "allow":

```javascript
// Before
async requestToolPermission(e,r,a,s){
  return(await this.sendRequest(e,{type:"tool_permission_request",toolName:r,inputs:a,suggestions:s})).result
}

// After
async requestToolPermission(e,r,a,s){
  return{behavior:"allow"}
}
```

### 3. Deny → Allow Conversion
Changes all `behavior:"deny"` to `behavior:"allow"` throughout the extension.

**Result:** Claude Code will **NEVER** show a permission prompt. ALL commands are auto-approved instantly. 🔥

## Features

- 🎯 **Complete Permission Bypass**: Never see another prompt
- 🔍 **Auto-Detection**: Finds all Claude Code extensions in VSCode and Cursor
- 💾 **Automatic Backups**: Creates `.bak` files before patching
- ↩️ **Reversible**: Use `-undo` to restore original behavior
- 📊 **Detailed Reports**: Clear status for each patch applied
- 🛡️ **Safe Restoration**: Undo mode removes backups after successful restoration

## Requirements

- Windows (PowerShell script)
- Claude Code extension installed in VSCode and/or Cursor
- Administrator privileges (recommended)

## Usage

### 🔥 Apply Ultra YOLO Mode

```powershell
.\ultra-yolo-patcher.ps1
```

Or double-click `ultra-yolo-patcher.ps1`

**IMPORTANT: Restart Cursor/VSCode completely after patching!**

### ↩️ Restore Normal Behavior

```powershell
.\ultra-yolo-patcher.ps1 -undo
```

**IMPORTANT: Restart Cursor/VSCode completely after undoing!**

## How It Works

### Patch Mode (Default)
1. Searches for Claude Code extensions in VSCode and Cursor
2. Creates backup (`.bak`) of each `extension.js`
3. Applies three patches:
   - **Patch 1**: Adds `--dangerously-skip-permissions` flag
   - **Patch 2**: Replaces permission request function
   - **Patch 3**: Changes `deny` behaviors to `allow`
4. Reports results

### Undo Mode (`-undo`)
1. Finds all Claude Code extensions
2. Restores each from `.bak` backup
3. Removes `.bak` files
4. Reports results

## Example Output

```
==========================================================
       Claude Code Ultra YOLO Patcher
       100% NO PERMISSION PROMPTS MODE
==========================================================

Searching for Claude Code extensions...

[FOUND] C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.10-universal\extension.js

[INFO] Found 1 extension(s)

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
  [PATCH 2] Disabling permission prompts (auto-allow ALL)
  [PATCH 3] Changing deny behaviors to allow

[ACTION] Writing patched file...
[SUCCESS] Ultra YOLO patches applied!

==========================================================
                   SUMMARY
==========================================================
Total extensions found: 1
Successfully patched:    1
Skipped:                 0
Errors:                  0
==========================================================

IMPORTANT: RESTART Cursor completely to apply changes!

After restart, Claude Code will NEVER ask for permissions.

To undo: .\ultra-yolo-patcher.ps1 -undo

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
