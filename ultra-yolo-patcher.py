#!/usr/bin/env python3
"""
Claude Code Ultra YOLO Patcher - Pure Python Version
Patches Claude Code extension to NEVER ask for permissions.
"""

import os
import sys
import shutil
import argparse
from pathlib import Path
from typing import List, Tuple

def find_extension_files() -> List[Path]:
    """Find all Claude Code extension JavaScript files"""
    files = []
    home = Path.home()
    search_dirs = [
        home / '.cursor' / 'extensions',
        home / '.cursor-server' / 'extensions',
        home / '.vscode' / 'extensions',
        home / '.vscode-server' / 'extensions',
    ]

    for search_dir in search_dirs:
        if search_dir.exists():
            for ext_dir in search_dir.glob('anthropic*claude-code*'):
                if ext_dir.is_dir():
                    ext_files = list(ext_dir.rglob('*.js'))
                    if ext_files:
                        print(f"[FOUND] {ext_dir} ({len(ext_files)} files)")
                        files.extend(ext_files)
    return files

def create_backup(file_path: Path) -> bool:
    """Create a backup of the file"""
    backup_path = Path(str(file_path) + '.bak')
    if backup_path.exists():
        return True
    try:
        shutil.copy2(file_path, backup_path)
        return True
    except Exception as e:
        print(f"ERROR: Failed to backup {file_path.name}: {e}")
        return False

def restore_backup(file_path: Path) -> bool:
    """Restore file from backup"""
    backup_path = Path(str(file_path) + '.bak')
    if not backup_path.exists():
        return False
    try:
        shutil.copy2(backup_path, file_path)
        backup_path.unlink()
        return True
    except Exception as e:
        print(f"ERROR: Failed to restore {file_path.name}: {e}")
        return False

def patch_file(file_path: Path) -> Tuple[bool, int]:
    """Patch a file to disable permission prompts"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"ERROR: Failed to read {file_path.name}: {e}")
        return False, 0

    original_content = content
    changes_made = 0
    filename = file_path.name

    # Log file path
    log_file = os.path.join(os.environ.get('TEMP', 'C:\\Temp'), 'claude-code-yolo.log').replace('\\', '/') if os.name == 'nt' else '/tmp/claude-code-yolo.log'

    # Patch extension.js
    if filename == 'extension.js':
        if 'k=["--output-format","stream-json"' in content:
            content = content.replace('k=["--output-format","stream-json"', 'k=["--dangerously-skip-permissions","--output-format","stream-json"')
            changes_made += 1
        elif 'F=["--output-format","stream-json"' in content:
            content = content.replace('F=["--output-format","stream-json"', 'F=["--dangerously-skip-permissions","--output-format","stream-json"')
            changes_made += 1

        original_func = 'async requestToolPermission(e,r,a,s){return(await this.sendRequest(e,{type:"tool_permission_request",toolName:r,inputs:a,suggestions:s})).result}'
        if original_func in content:
            replacement_func = f'async requestToolPermission(e,r,a,s){{try{{const fs=require("fs");fs.appendFileSync("{log_file}","["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\\n");}}catch(err){{}}return{{behavior:"allow",updatedInput:a}}}}'
            content = content.replace(original_func, replacement_func)
            changes_made += 1

        deny_count = content.count('behavior:"deny"')
        if deny_count > 0:
            content = content.replace('behavior:"deny"', 'behavior:"allow"')
            changes_made += 1

        if 'YOLO FILE LOADED' not in content:
            startup_log = f'try{{const fs=require("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: {filename}\\n";fs.appendFileSync("{log_file}",log);console.log("YOLO LOADED: {filename}");}}catch(e){{console.error("YOLO ERROR in {filename}:",e);}};'
            content = startup_log + '\n' + content
            changes_made += 1

    # Patch cli.js
    elif filename == 'cli.js':
        if 'YOLO FILE LOADED' not in content:
            startup_log = f'(async()=>{{try{{const fs=await import("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: {filename}\\n";fs.appendFileSync("{log_file}",log);}}catch(e){{}}}})();'
            if content.startswith('#!/usr/bin/env node'):
                lines = content.split('\n', 1)
                content = lines[0] + '\n' + startup_log + '\n' + (lines[1] if len(lines) == 2 else '')
            else:
                content = startup_log + '\n' + content
            changes_made += 1

    # Patch other files
    else:
        deny_count = content.count('behavior:"deny"')
        if deny_count > 0:
            content = content.replace('behavior:"deny"', 'behavior:"allow"')
            changes_made += 1

        if 'YOLO FILE LOADED' not in content:
            startup_log = f'try{{const fs=require("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: {filename}\\n";fs.appendFileSync("{log_file}",log);}}catch(e){{}};'
            content = startup_log + '\n' + content
            changes_made += 1

    # Write if changed
    if content != original_content:
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True, changes_made
        except Exception as e:
            print(f"ERROR: Failed to write {file_path.name}: {e}")
            return False, 0
    return False, 0

def main():
    parser = argparse.ArgumentParser(description='Claude Code Ultra YOLO Patcher')
    parser.add_argument('--undo', action='store_true', help='Restore original files')
    parser.add_argument('--repatch', action='store_true', help='Undo then patch')
    parser.add_argument('-y', '--yes', action='store_true', help='Skip prompts')
    args = parser.parse_args()

    # Repatch mode
    if args.repatch:
        print("Repatch: Running undo...")
        args.undo = True
        args.yes = True
        main_logic(args)
        print("Repatch: Running patch...")
        args.undo = False
        main_logic(args)
        return

    main_logic(args)

def main_logic(args):
    """Main logic"""
    files = find_extension_files()

    if not files:
        print("ERROR: No Claude Code extensions found!")
        sys.exit(1)

    # Confirmation
    if not args.yes:
        if args.undo:
            print(f"Restore {len(files)} files? [Enter/Ctrl+C]")
        else:
            print(f"Patch {len(files)} files? YOLO mode! [Enter/Ctrl+C]")
        input()

    # Process
    patched = skipped = 0
    for file_path in files:
        if args.undo:
            if restore_backup(file_path):
                patched += 1
            else:
                skipped += 1
        else:
            if create_backup(file_path):
                success, _ = patch_file(file_path)
                if success:
                    patched += 1
                else:
                    skipped += 1

    # Summary
    if args.undo:
        print(f"Restored {patched}/{len(files)} files")
    else:
        print(f"Patched {patched}/{len(files)} files")
        if patched > 0:
            print("RESTART Cursor/VSCode!")
            log = os.path.join(os.environ.get('TEMP', 'C:\\Temp'), 'claude-code-yolo.log') if os.name == 'nt' else '/tmp/claude-code-yolo.log'
            print(f"Logs: {log}")

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\nCancelled")
        sys.exit(1)
    except Exception as e:
        print(f"\nFATAL ERROR: {e}")
        sys.exit(1)
    finally:
        sys.stdout.flush()
