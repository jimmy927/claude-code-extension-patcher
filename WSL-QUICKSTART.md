# WSL/Linux Quick Start Guide

## Quick Setup

1. **Make script executable:**
   ```bash
   chmod +x ultra-yolo-patcher.sh
   ```

2. **Run the patcher:**
   ```bash
   ./ultra-yolo-patcher.sh
   ```

3. **Restart Cursor completely**

4. **Verify it works:**
   ```bash
   # Check the log file
   tail -f /tmp/claude-code-yolo.log
   ```

## Extension Locations

The bash script will automatically search for Claude Code extensions in:

- `~/.cursor-server/extensions/anthropic*claude-code*`
- `~/.vscode-server/extensions/anthropic*claude-code*`
- `~/.vscode/extensions/anthropic*claude-code*`

## Your WSL Installation

Based on your output, your extension is at:
```
/home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal
```

## Commands

### Apply patches
```bash
./ultra-yolo-patcher.sh
```

### Undo patches
```bash
./ultra-yolo-patcher.sh -undo
```

### Repatch (undo + patch)
```bash
./ultra-yolo-patcher.sh -repatch
```

### Silent mode (no prompts)
```bash
./ultra-yolo-patcher.sh -yes
```

## Log File

All permission logs are written to:
```
/tmp/claude-code-yolo.log
```

View logs:
```bash
# View entire log
cat /tmp/claude-code-yolo.log

# Monitor in real-time
tail -f /tmp/claude-code-yolo.log

# View last 20 lines
tail -20 /tmp/claude-code-yolo.log
```

## Expected Output

After running the patcher, you should see something like:

```
==========================================================
       Claude Code Ultra YOLO Patcher
       100% NO PERMISSION PROMPTS MODE
==========================================================

Searching for Claude Code extensions...

[FOUND] /home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal/extension.js
[FOUND] /home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal/resources/claude-code/cli.js
[FOUND] /home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal/webview/index.js

[INFO] Found 3 file(s)

...

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
  /tmp/claude-code-yolo.log
```

## Troubleshooting

**"Permission denied" when running script:**
```bash
chmod +x ultra-yolo-patcher.sh
```

**"perl: command not found":**
```bash
# Ubuntu/Debian
sudo apt-get install perl

# Fedora/RHEL
sudo yum install perl

# Arch
sudo pacman -S perl
```

**Extension not found:**
- Make sure Cursor is installed and has been run at least once in WSL
- Check that the extension path exists:
  ```bash
  ls -la ~/.cursor-server/extensions/anthropic*claude-code*
  ```

## Notes

- The bash script works identically to the PowerShell version
- All patches are the same (Patch 1, 2, 3, 3b, 3c, 4)
- Backups are created with `.bak` extension
- Log file location is `/tmp/claude-code-yolo.log` (Linux standard)
