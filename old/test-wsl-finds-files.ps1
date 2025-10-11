#!/usr/bin/env pwsh

Write-Host "TEST: Check if WSL patcher finds any files"
Write-Host ""

$Code = @"
import sys
from pathlib import Path

home = Path.home()
search_dirs = [
    home / '.cursor' / 'extensions',
    home / '.cursor-server' / 'extensions',
    home / '.vscode' / 'extensions',
    home / '.vscode-server' / 'extensions',
]

print(f'WSL Home: {home}')
print()
print('Searching for Claude Code extensions...')
print()

files = []
for search_dir in search_dirs:
    print(f'Checking: {search_dir}')
    if search_dir.exists():
        print(f'  EXISTS')
        for ext_dir in search_dir.glob('anthropic*claude-code*'):
            if ext_dir.is_dir():
                for js_file in ext_dir.rglob('*.js'):
                    files.append(js_file)
                    print(f'  [FOUND] {js_file}')
    else:
        print(f'  NOT FOUND')
    print()

print(f'Total files found: {len(files)}')
"@

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
