#!/usr/bin/env pwsh

Write-Host "TEST: Large output via WSL stdin"
Write-Host ""

$Code = @"
import sys
sys.argv = ['test.py']

# Simulate patcher output
for i in range(100):
    print('=' * 60)
    print(f'[INFO] Processing file {i}')
    print('[ACTION] Creating backup...')
    print('[SUCCESS] Backup created')
    print('[ACTION] Applying YOLO patches...')
    print('  [PATCH 1] Pattern found')
    print('  [PATCH 2] Pattern found')
    print('[SUCCESS] Patches applied!')
    print()

print('All done!')
"@

Write-Host "Running large output test..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
