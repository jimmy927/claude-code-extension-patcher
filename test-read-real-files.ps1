#!/usr/bin/env pwsh

Write-Host "TEST: Read actual extension files from /mnt/c/ via WSL stdin"
Write-Host ""

$Code = @"
import sys
from pathlib import Path

# Find actual extension file
home = Path.home()
search_dir = home / '.cursor-server' / 'extensions'

print('Finding files...')
files = []
if search_dir.exists():
    for ext_dir in search_dir.glob('anthropic*claude-code*'):
        if ext_dir.is_dir():
            for js_file in list(ext_dir.rglob('*.js'))[:2]:  # Only first 2
                files.append(js_file)
                print(f'Found: {js_file}')

print()
print(f'Reading {len(files)} files...')
print()

for f in files:
    print(f'Reading: {f.name}')
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
            print(f'  Size: {len(content)} bytes')
    except Exception as e:
        print(f'  Error: {e}')
    print()

print('Done!')
"@

Write-Host "Running file read test..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
