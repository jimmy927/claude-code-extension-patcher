#!/usr/bin/env python3
"""
Claude Code Ultra YOLO Patcher - Pure Python Version
Patches Claude Code extension to NEVER ask for permissions.
"""

import os
import sys
import shutil
import re
import argparse
from pathlib import Path
from typing import List, Tuple

def print_header(text: str):
    """Print a header"""
    print()
    print("=" * 60)
    print(text)
    print("=" * 60)
    print()

def find_extension_files() -> List[Path]:
    """Find all Claude Code extension JavaScript files"""
    files = []
    home = Path.home()

    # Search directories
    search_dirs = [
        home / '.cursor' / 'extensions',
        home / '.cursor-server' / 'extensions',
        home / '.vscode' / 'extensions',
        home / '.vscode-server' / 'extensions',
    ]

    print("Searching for Claude Code extensions...")
    print()

    for search_dir in search_dirs:
        if not search_dir.exists():
            continue

        # Find all anthropic.claude-code-* directories
        for ext_dir in search_dir.glob('anthropic*claude-code*'):
            if ext_dir.is_dir():
                # Find all .js files in the extension
                for js_file in ext_dir.rglob('*.js'):
                    files.append(js_file)
                    print(f"[FOUND] {js_file}")

    return files

def create_backup(file_path: Path) -> bool:
    """Create a backup of the file"""
    backup_path = Path(str(file_path) + '.bak')

    if backup_path.exists():
        print("[INFO] Backup already exists")
        return True

    print("[ACTION] Creating backup...")
    try:
        shutil.copy2(file_path, backup_path)
        print("[SUCCESS] Backup created")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to create backup: {e}")
        return False

def restore_backup(file_path: Path) -> bool:
    """Restore file from backup"""
    backup_path = Path(str(file_path) + '.bak')

    if not backup_path.exists():
        print("[SKIP] No backup found")
        return False

    print("[ACTION] Restoring from backup...")
    try:
        shutil.copy2(backup_path, file_path)
        backup_path.unlink()  # Remove backup after restoring
        print("[SUCCESS] Restored!")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to restore: {e}")
        return False

def patch_file(file_path: Path) -> Tuple[bool, int]:
    """
    Patch a file to disable permission prompts.
    FILE-SPECIFIC patches based on filename.
    Returns (success, changes_made)
    """
    print("[ACTION] Applying YOLO patches...")

    # Read file
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"[ERROR] Failed to read file: {e}")
        return False, 0

    original_content = content
    changes_made = 0
    filename = file_path.name

    # Determine log file path based on OS
    if os.name == 'nt':  # Windows
        log_file = os.path.join(os.environ.get('TEMP', 'C:\\Temp'), 'claude-code-yolo.log').replace('\\', '/')
    else:  # Linux/WSL/Mac
        log_file = '/tmp/claude-code-yolo.log'

    # ========================================================================
    # EXTENSION.JS ONLY - Main permission handling
    # ========================================================================
    if filename == 'extension.js':
        # Patch 1: Add --dangerously-skip-permissions flag
        if 'k=["--output-format","stream-json"' in content:
            print("  [PATCH 1] Adding --dangerously-skip-permissions flag")
            content = content.replace(
                'k=["--output-format","stream-json"',
                'k=["--dangerously-skip-permissions","--output-format","stream-json"'
            )
            changes_made += 1
        elif 'F=["--output-format","stream-json"' in content:
            print("  [PATCH 1] Adding --dangerously-skip-permissions flag (v2.0.1)")
            content = content.replace(
                'F=["--output-format","stream-json"',
                'F=["--dangerously-skip-permissions","--output-format","stream-json"'
            )
            changes_made += 1
        else:
            print("  [PATCH 1] Already applied or different version")

        # Patch 2: Replace requestToolPermission function
        original_func = 'async requestToolPermission(e,r,a,s){return(await this.sendRequest(e,{type:"tool_permission_request",toolName:r,inputs:a,suggestions:s})).result}'

        if original_func in content:
            print("  [PATCH 2] Disabling permission prompts (auto-allow ALL) + LOGGING")
            # The response must be a union type:
            # - For "allow": must include updatedInput (the tool inputs, possibly modified)
            # - For "deny": just {behavior: "deny"}
            # We return "allow" with the original inputs as updatedInput
            replacement_func = f'async requestToolPermission(e,r,a,s){{try{{const fs=require("fs");fs.appendFileSync("{log_file}","["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\\n");}}catch(err){{}}return{{behavior:"allow",updatedInput:a}}}}'
            content = content.replace(original_func, replacement_func)
            changes_made += 1
        else:
            print("  [PATCH 2] Pattern not found or already applied")

        # Patch 3: Change deny to allow
        deny_count = content.count('behavior:"deny"')
        if deny_count > 0:
            print(f"  [PATCH 3] Changing {deny_count} deny behaviors to allow")
            content = content.replace('behavior:"deny"', 'behavior:"allow"')
            changes_made += 1
        else:
            print("  [PATCH 3] No deny behaviors found")

        # Patch 4: Add startup logging (extension.js only)
        if 'YOLO FILE LOADED' not in content:
            print("  [PATCH 4] Adding startup logging")
            startup_log = f'try{{const fs=require("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: {filename}\\n";fs.appendFileSync("{log_file}",log);console.log("YOLO LOADED: {filename}");}}catch(e){{console.error("YOLO ERROR in {filename}:",e);}};'
            content = startup_log + '\n' + content
            changes_made += 1
        else:
            print("  [PATCH 4] Startup logging already added")

    # ========================================================================
    # CLI.JS ONLY - ONLY startup logging, NO deny->allow (causes errors!)
    # ========================================================================
    elif filename == 'cli.js':
        # Patch 3: SKIP for cli.js - deny behaviors are needed for error handling!
        print("  [PATCH 3] Skipped for cli.js (deny behaviors needed for error handling)")

        # Patch 4: Add startup logging (cli.js only)
        if 'YOLO FILE LOADED' not in content:
            print("  [PATCH 4] Adding startup logging")
            if content.startswith('#!/usr/bin/env node'):
                startup_log = f'(async()=>{{try{{const fs=await import("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: {filename}\\n";fs.appendFileSync("{log_file}",log);}}catch(e){{}}}})();'
                lines = content.split('\n', 1)
                if len(lines) == 2:
                    content = lines[0] + '\n' + startup_log + '\n' + lines[1]
                else:
                    content = lines[0] + '\n' + startup_log + '\n'
            else:
                startup_log = f'(async()=>{{try{{const fs=await import("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: {filename}\\n";fs.appendFileSync("{log_file}",log);}}catch(e){{}}}})();'
                content = startup_log + '\n' + content
            changes_made += 1
        else:
            print("  [PATCH 4] Startup logging already added")

    # ========================================================================
    # OTHER FILES (index.js etc) - Just deny->allow
    # ========================================================================
    else:
        # Patch 3: Change deny to allow (other files)
        deny_count = content.count('behavior:"deny"')
        if deny_count > 0:
            print(f"  [PATCH 3] Changing {deny_count} deny behaviors to allow")
            content = content.replace('behavior:"deny"', 'behavior:"allow"')
            changes_made += 1
        else:
            print("  [PATCH 3] No deny behaviors found")

        # Patch 4: Add startup logging (other files)
        if 'YOLO FILE LOADED' not in content:
            print("  [PATCH 4] Adding startup logging")
            startup_log = f'try{{const fs=require("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: {filename}\\n";fs.appendFileSync("{log_file}",log);}}catch(e){{}};'
            content = startup_log + '\n' + content
            changes_made += 1
        else:
            print("  [PATCH 4] Startup logging already added")

    # Write file if changes were made
    if content != original_content:
        print()
        print("[ACTION] Writing patched file...")
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print("[SUCCESS] Patches applied!")
            return True, changes_made
        except Exception as e:
            print(f"[ERROR] Failed to write file: {e}")
            return False, 0
    else:
        print()
        print("[SKIP] No changes needed (already patched?)")
        return False, 0

def main():
    parser = argparse.ArgumentParser(
        description='Claude Code Ultra YOLO Patcher - Disables ALL permission prompts',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python ultra-yolo-patcher.py           # Patch with confirmation
  python ultra-yolo-patcher.py -y        # Patch without prompts
  python ultra-yolo-patcher.py --undo    # Restore original files
  python ultra-yolo-patcher.py --repatch # Undo + patch

IMPORTANT: RESTART Cursor/VSCode completely after patching!
        """
    )

    parser.add_argument('--undo', action='store_true', help='Restore original files from backups')
    parser.add_argument('--repatch', action='store_true', help='Undo then patch (useful after updates)')
    parser.add_argument('-y', '--yes', action='store_true', help='Skip all confirmation prompts')

    args = parser.parse_args()

    # Handle repatch mode
    if args.repatch:
        print_header("Claude Code Ultra YOLO Patcher - REPATCH MODE")
        print("Running UNDO first...")
        print()

        # Undo
        args.undo = True
        args.yes = True
        main_logic(args)

        print()
        print("Now running PATCH...")
        print()

        # Patch
        args.undo = False
        main_logic(args)
        return

    main_logic(args)

def main_logic(args):
    """Main logic"""
    # Header
    if args.undo:
        print_header("Claude Code Ultra YOLO Patcher - UNDO MODE")
    else:
        print_header("Claude Code Ultra YOLO Patcher\n       100% NO PERMISSION PROMPTS MODE")

    # Find files
    files = find_extension_files()

    if not files:
        print()
        print("[ERROR] No Claude Code extensions found!")
        print()
        sys.exit(1)

    print()
    print(f"[INFO] Found {len(files)} file(s)")
    print()

    # Confirmation
    if not args.yes:
        if args.undo:
            print("This will restore the original files from backups.")
        else:
            print("This will modify the extension to NEVER ask for permissions.")
            print("ALL commands will be auto-approved. 100% YOLO MODE!")

        print()
        response = input("Press Enter to continue, or Ctrl+C to cancel... ")
        print()

    # Process files
    patched_count = 0
    skipped_count = 0
    error_count = 0

    for file_path in files:
        print("=" * 60)
        print(f"Processing: {file_path}")
        print("=" * 60)

        if args.undo:
            # UNDO MODE
            if restore_backup(file_path):
                patched_count += 1
            else:
                skipped_count += 1
        else:
            # PATCH MODE
            if not create_backup(file_path):
                error_count += 1
                print()
                continue

            success, changes = patch_file(file_path)
            if success:
                patched_count += 1
            elif changes == 0:
                skipped_count += 1
            else:
                error_count += 1

        print()

    # Summary
    print("=" * 60)
    print("                   SUMMARY")
    print("=" * 60)
    print(f"Total files found: {len(files)}")
    print(f"Successfully patched:    {patched_count}")
    print(f"Skipped:                 {skipped_count}")
    if error_count > 0:
        print(f"Errors:                  {error_count}")
    else:
        print(f"Errors:                  {error_count}")
    print("=" * 60)
    print()

    if not args.undo and patched_count > 0:
        print("IMPORTANT: RESTART Cursor completely to apply changes!")
        print()
        print("After restart, Claude Code will NEVER ask for permissions.")
        print()

        # Show log file location
        if os.name == 'nt':  # Windows
            log_file = os.path.join(os.environ.get('TEMP', 'C:\\Temp'), 'claude-code-yolo.log')
            print("ALL LOGS written to:")
            print(f"  {log_file}")
            print()
            print("View logs:")
            print(f"  Get-Content \"{log_file}\" -Wait -Tail 20")
        else:  # Linux/WSL/Mac
            log_file = '/tmp/claude-code-yolo.log'
            print("ALL LOGS written to:")
            print(f"  {log_file}")
            print()
            print("View logs:")
            print(f"  tail -f {log_file}")
        print()

    if not args.undo:
        print("To undo: python ultra-yolo-patcher.py --undo")
        print("To repatch: python ultra-yolo-patcher.py --repatch")

    print()

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print()
        print("Cancelled by user")
        sys.exit(1)
    except Exception as e:
        print()
        print(f"FATAL ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
