#!/usr/bin/env pwsh

Write-Host "TEST: Simulating patcher execution flow via WSL stdin"
Write-Host ""

$Code = @"
import sys
import argparse
from pathlib import Path

sys.argv = ['patcher.py', '-y']

# Simulate the patcher structure
parser = argparse.ArgumentParser(description='Test patcher')
parser.add_argument('-y', '--yes', action='store_true')
args = parser.parse_args()

print()
print('=' * 60)
print('TEST PATCHER')
print('=' * 60)
print()

# Find some files
home = Path.home()
files = []
search_dir = home / '.cursor' / 'extensions'
if search_dir.exists():
    for item in list(search_dir.glob('anthropic*'))[:3]:
        files.append(item)
        print(f'[FOUND] {item}')

print()
print(f'[INFO] Found {len(files)} files')
print()

# Simulate confirmation (should be skipped with -y)
if not args.yes:
    response = input('Press Enter to continue... ')
    print()

# Process files
for f in files:
    print('=' * 60)
    print(f'Processing: {f}')
    print('=' * 60)
    print('[ACTION] Creating backup...')
    print('[SUCCESS] Backup created')
    print()

print('=' * 60)
print('SUMMARY')
print('=' * 60)
print(f'Total: {len(files)}')
print()
print('Done!')
"@

Write-Host "Running patcher flow simulation..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
