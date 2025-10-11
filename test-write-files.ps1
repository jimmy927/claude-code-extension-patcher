#!/usr/bin/env pwsh

Write-Host "TEST: Write actual files via WSL stdin"
Write-Host ""

$Code = @"
import sys
import shutil
from pathlib import Path

# Test writing in WSL temp
temp_dir = Path('/tmp/test-patcher')
temp_dir.mkdir(exist_ok=True)

test_file = temp_dir / 'test.txt'
backup_file = temp_dir / 'test.txt.bak'

print('Writing test file...')
with open(test_file, 'w', encoding='utf-8') as f:
    f.write('This is a test file' * 1000)  # Make it bigger
print(f'Wrote: {test_file}')
print()

print('Creating backup with shutil.copy2...')
shutil.copy2(test_file, backup_file)
print(f'Backed up: {backup_file}')
print()

print('Reading back...')
with open(test_file, 'r', encoding='utf-8') as f:
    content = f.read()
    print(f'Read {len(content)} bytes')
print()

print('Modifying and writing...')
modified = content.replace('test', 'TEST')
with open(test_file, 'w', encoding='utf-8') as f:
    f.write(modified)
print(f'Modified: {test_file}')
print()

print('Cleanup...')
test_file.unlink()
backup_file.unlink()
temp_dir.rmdir()
print('Done!')
"@

Write-Host "Running file write test..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
