#!/usr/bin/env python3
"""
Archive Current Extension
Archives the current Claude Code extension to extension-archive with version number
"""

import os
import sys
import shutil
import json
import re
import argparse
from pathlib import Path
from typing import Optional

def find_current_extension() -> Optional[Path]:
    """Find the current Claude Code extension directory"""
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
                    print(f"[FOUND] Extension: {ext_dir}")
                    return ext_dir
    return None

def get_extension_version(ext_dir: Path) -> Optional[str]:
    """Extract version from package.json or directory name"""
    # Try package.json first
    package_json = ext_dir / 'package.json'
    if package_json.exists():
        try:
            with open(package_json, 'r', encoding='utf-8') as f:
                data = json.load(f)
                version = data.get('version')
                if version:
                    print(f"[VERSION] Found in package.json: {version}")
                    return version
        except Exception as e:
            print(f"[WARNING] Failed to read package.json: {e}")

    # Try directory name
    match = re.search(r'(\d+\.\d+\.\d+)', ext_dir.name)
    if match:
        version = match.group(1)
        print(f"[VERSION] Extracted from directory name: {version}")
        return version

    return None

def archive_extension(ext_dir: Path, version: str, archive_base: Path, force: bool = False):
    """Archive extension files to extension-archive"""
    archive_dir = archive_base / version

    # Check if already archived
    if archive_dir.exists():
        if not force:
            print(f"[ERROR] Version {version} is already archived at: {archive_dir}")
            print(f"[ERROR] Use --force to overwrite existing archive")
            return False
        else:
            print(f"[FORCE] Removing existing archive: {archive_dir}")
            shutil.rmtree(archive_dir)

    # Copy only .js files while preserving directory structure
    print(f"[ARCHIVING] Copying .js files...")
    archived_count = 0

    try:
        for js_file in ext_dir.rglob('*.js'):
            # Get relative path from extension directory
            rel_path = js_file.relative_to(ext_dir)
            dest = archive_dir / rel_path

            # Create parent directories
            dest.parent.mkdir(parents=True, exist_ok=True)

            # Copy the file
            shutil.copy2(js_file, dest)
            print(f"[ARCHIVED] {rel_path}")
            archived_count += 1

        print(f"\n[SUCCESS] Archived {archived_count} .js files to {archive_dir}")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to archive: {e}")
        return False

def main():
    # Parse arguments
    parser = argparse.ArgumentParser(description='Archive Current Claude Code Extension')
    parser.add_argument('-y', '--yes', action='store_true', help='Skip confirmation prompts')
    parser.add_argument('-f', '--force', action='store_true', help='Force overwrite if version already archived')
    args = parser.parse_args()

    # Find current extension
    ext_dir = find_current_extension()
    if not ext_dir:
        print("[ERROR] No Claude Code extension found!")
        sys.exit(1)

    # Get version
    version = get_extension_version(ext_dir)
    if not version:
        print("[ERROR] Could not determine extension version!")
        sys.exit(1)

    # Archive base directory
    script_dir = Path(__file__).parent
    archive_base = script_dir / 'extension-archive'

    # Confirm
    print(f"\n[SUMMARY]")
    print(f"  Extension: {ext_dir}")
    print(f"  Version: {version}")
    print(f"  Archive to: {archive_base / version}")
    print()

    if not args.yes:
        response = input("Proceed with archiving? [Y/n]: ").strip().lower()
        if response and response != 'y':
            print("[CANCELLED] Archive cancelled by user")
            sys.exit(0)

    # Archive
    success = archive_extension(ext_dir, version, archive_base, force=args.force)
    if not success:
        sys.exit(1)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n[CANCELLED] Archive cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n[FATAL ERROR] {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
