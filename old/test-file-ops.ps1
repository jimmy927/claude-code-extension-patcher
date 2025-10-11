#!/usr/bin/env pwsh

Write-Host "TEST: File operations via WSL stdin"
Write-Host ""

$Code = @"
import sys
import os
from pathlib import Path

sys.argv = ['test.py']

# Try to find files like the patcher does
home = Path.home()
search_dirs = [
    home / '.cursor' / 'extensions',
    home / '.vscode' / 'extensions',
]

print('Searching for extensions...')
print()

found_files = []
for search_dir in search_dirs:
    if search_dir.exists():
        for item in list(search_dir.glob('anthropic*claude-code*'))[:5]:  # Limit to 5
            print(f'[FOUND] {item}')
            found_files.append(item)

print()
print(f'Total: {len(found_files)} files')
print()
print('Done!')
"@

Write-Host "Running file ops test..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
