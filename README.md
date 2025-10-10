# Claude Code VSCode Extension Patcher

A Windows batch script that modifies the Claude Code VSCode extension to add the `--dangerously-skip-permissions` launch argument.

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

- **Automatic Backup**: Creates a backup of the original `extension.js` file before making any changes
- **Safety Checks**:
  - Verifies the target file exists
  - Checks if the file has already been patched
  - Validates the original pattern exists before attempting replacement
- **User-Friendly**: Clear console output with status messages throughout the patching process
- **Reversible**: Includes backup file for easy restoration if needed

## Requirements

- Windows operating system
- PowerShell (included with Windows)
- Claude Code VSCode extension installed

## Usage

1. Locate your Claude Code extension directory:
   - Typically found at: `%USERPROFILE%\.vscode\extensions\anthropic.claude-code-*\dist\`
   - Or: `C:\Users\YourUsername\.vscode\extensions\anthropic.claude-code-*\dist\`

2. Copy `patcher.ps1` to the same directory as `extension.js`

3. Run the script:
   - Double-click `patcher.ps1`, or
   - Right-click and select "Run with PowerShell"

4. Follow the on-screen prompts

5. Restart VSCode for changes to take effect

## Restoring the Original File

If you need to restore the original extension file:

1. Navigate to the extension directory
2. Delete the modified `extension.js`
3. Rename `extension.js.bak` to `extension.js`
4. Restart VSCode

## How It Works

1. **Validation**: Checks if `extension.js` exists in the same directory
2. **Duplicate Check**: Verifies the file hasn't already been patched
3. **Pattern Match**: Confirms the original arguments array is present
4. **Backup**: Creates `extension.js.bak` (if it doesn't already exist)
5. **Replacement**: Uses PowerShell regex to modify the arguments array
6. **Verification**: Confirms the patch was applied successfully

## Troubleshooting

**"extension.js not found"**
- Ensure the script is in the same directory as `extension.js`
- Verify the Claude Code extension is installed

**"Already patched"**
- The file has already been modified by this script
- No further action needed

**"Original arguments array not found"**
- The extension may have been updated to a different version
- The file structure may have changed
- Manual inspection of `extension.js` may be required

**Permission Errors**
- Run the script as Administrator
- Check file permissions on `extension.js`

## Security Considerations

The `--dangerously-skip-permissions` flag bypasses permission checks. Consider the following:

- This may expose your system to security risks
- Only use this if you understand the implications
- Keep your system and VSCode updated
- Use caution when working with sensitive files or data

## Credit

Original implementation: [GitHub Issue Comment](https://github.com/anthropics/claude-code/issues/8539#issuecomment-3389961296)

## License

This script is provided as-is for educational and convenience purposes. Use at your own discretion and risk.

---

**Remember: You are solely responsible for any consequences of using this modification.**
