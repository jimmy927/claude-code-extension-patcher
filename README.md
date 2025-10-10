# Claude Code VSCode Extension Patcher

A Windows PowerShell script that modifies the Claude Code VSCode extension to add the `--dangerously-skip-permissions` launch argument.

**v5 - Multi-Extension Support**: Now patches all Claude Code extensions found in both VSCode and Cursor!

## ⚠️ DISCLAIMER

**USE AT YOUR OWN RISK**

This script modifies the Claude Code VSCode extension files. By using this patcher, you acknowledge and agree that:

- **NO WARRANTY**: This software is provided "as is" without warranty of any kind, either expressed or implied.
- **NO LIABILITY**: The authors and contributors are not liable for any damages, data loss, security issues, or other consequences resulting from the use of this script.
- **MODIFICATION RISKS**: Modifying extension files may cause instability, unexpected behavior, or break functionality.
- **NO OFFICIAL SUPPORT**: This is an unofficial modification and is not supported or endorsed by Anthropic or the Claude Code development team.
- **YOUR RESPONSIBILITY**: You are solely responsible for any consequences of using this script, including potential security implications of bypassing permission checks.

**By using this script, you accept full responsibility for any and all consequences.**

---

## What This Script Does

This patcher modifies the `extension.js` file of the Claude Code VSCode extension by adding the `--dangerously-skip-permissions` flag to the launch arguments array.

**Specifically, it changes:**

```javascript
k=["--output-format","stream-json","--verbose","--input-format","stream-json"]
```

**To:**

```javascript
k=["--dangerously-skip-permissions","--output-format","stream-json","--verbose","--input-format","stream-json"]
```

This modification bypasses certain permission checks in the Claude Code extension.

## Features

- **Multi-Extension Support**: Automatically finds and patches ALL Claude Code extensions in VSCode and Cursor
- **Auto-Detection**: Searches in standard extension directories for both editors
- **Version Support**: Handles both old (dist/) and new (root) extension structures
- **Undo Functionality**: Built-in `--undo` option to restore all backups with one command
- **Automatic Backup**: Creates a backup of each original `extension.js` file before making changes
- **Safety Checks**:
  - Verifies the target files exist
  - Checks if files have already been patched
  - Validates the original pattern exists before attempting replacement
- **Detailed Reporting**: Shows summary of patched, skipped, and failed files
- **User-Friendly**: Clear console output with status messages throughout the process
- **Reversible**: Includes backup files for easy restoration

## Requirements

- Windows operating system (currently Windows only - we'd love to receive PRs for Mac & Linux support!)
- PowerShell (included with Windows)
- Claude Code extension installed in VSCode and/or Cursor

## Usage

### Patching Extensions

Run the script from any location:

```powershell
.\patcher.ps1
```

Or simply double-click `patcher.ps1`

The script will:
1. Automatically search for Claude Code extensions in:
   - `%USERPROFILE%\.vscode\extensions\`
   - `%USERPROFILE%\.cursor\extensions\`
2. Find all versions (supports both old and new extension structures)
3. Patch all found extensions
4. Show a detailed summary

**After patching, restart VSCode/Cursor for changes to take effect.**

### Undoing Changes

To restore all original files from backups:

```powershell
.\patcher.ps1 -undo
```

The script will:
1. Find all Claude Code extensions (same as patch mode)
2. Restore each one from its `.bak` backup file
3. Remove the `.bak` files after successful restoration
4. Show a detailed summary

**After undoing, restart VSCode/Cursor for changes to take effect.**

## How It Works

### Patch Mode (Default)
1. **Search**: Scans VSCode and Cursor extension directories
2. **Discovery**: Finds all Claude Code extension versions
3. **Validation**: For each extension:
   - Checks if already patched (skips if yes)
   - Confirms the original pattern exists
4. **Backup**: Creates `extension.js.bak` (if it doesn't already exist)
5. **Replacement**: Uses PowerShell regex to modify the arguments array
6. **Summary**: Reports success/skip/error counts

### Undo Mode (`-undo`)
1. **Search**: Scans VSCode and Cursor extension directories
2. **Discovery**: Finds all Claude Code extension versions
3. **Restoration**: For each extension:
   - Checks if backup exists
   - Restores original file from `.bak` (by renaming)
   - Removes `.bak` file after successful restoration
4. **Summary**: Reports restoration results

## Example Output

### Patch Mode
```
==========================================================
       Claude Code Patcher (v5 - Multi-Extension)
==========================================================
This script will modify 'extension.js' to add the
'--dangerously-skip-permissions' launch argument.

Searching for Claude Code extensions in VSCode and Cursor...

[SEARCH] Looking in VSCode extensions...
[SEARCH] Looking in Cursor extensions...
[FOUND] C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.1-universal\extension.js
[FOUND] C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.10-universal\extension.js

[INFO] Found 2 extension(s) to process.

A backup of each original file will be created before any changes are made.

Press any key to continue, or close this window to cancel.

==========================================================
Processing: C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.1-universal\extension.js
==========================================================
[DETECT] Detected v2.0.1 (F variable)
[ACTION] Creating backup as 'extension.js.bak'...
[SUCCESS] Backup created.
[ACTION] Patching the file...
[SUCCESS] File patched successfully!

==========================================================
Processing: C:\Users\jimmy\.cursor\extensions\anthropic.claude-code-2.0.10-universal\extension.js
==========================================================
[DETECT] Detected v2.0.10+ (k variable)
[ACTION] Creating backup as 'extension.js.bak'...
[SUCCESS] Backup created.
[ACTION] Patching the file...
[SUCCESS] File patched successfully!

==========================================================
                   PATCH SUMMARY
==========================================================
Total extensions found: 2
Successfully patched:    2
Skipped (already done): 0
Errors:                 0
==========================================================

Press any key to exit...
```

### Undo Mode
```
==========================================================
          Claude Code Patcher (v5 - UNDO MODE)
==========================================================

[INFO] Found 2 extension(s) to process.

[ACTION] Restoring from backup...
[SUCCESS] File restored and backup removed!

==========================================================
                   UNDO SUMMARY
Total extensions found: 2
Successfully restored:   2
Skipped (no backup):    0
Errors:                 0
==========================================================
```

## Troubleshooting

**"extension.js not found"**
- Verify Claude Code extension is installed in VSCode or Cursor
- Check that you're running the script with proper permissions

**"Already patched"**
- The files have already been modified by this script
- No further action needed

**"Original arguments array not found"**
- The extension may have been updated to a different version
- The file structure may have changed
- Try running with `-undo` to restore, then update the extension

**Permission Errors**
- Run PowerShell as Administrator
- Check file permissions on extension directories

**"No backup file found" (in undo mode)**
- The extension was never patched with this script
- Or the backup file was manually deleted

## Security Considerations

The `--dangerously-skip-permissions` flag bypasses permission checks. Consider the following:

- This may expose your system to security risks
- Only use this if you understand the implications
- Keep your system and VSCode updated
- Use caution when working with sensitive files or data

## Credit

Original implementation: [GitHub Issue Comment](https://github.com/anthropics/claude-code/issues/8539#issuecomment-3389961296)

Created by: [@lifodetails](https://github.com/lifodetails)

## License

This script is provided as-is for educational and convenience purposes. Use at your own discretion and risk.

---

**Remember: You are solely responsible for any consequences of using this modification.**
