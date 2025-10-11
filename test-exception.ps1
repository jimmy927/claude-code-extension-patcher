#!/usr/bin/env pwsh

Write-Host "TEST: Simulating patcher with exception and traceback"
Write-Host ""

$Code = @"
import sys
import traceback

sys.argv = ['patcher.py']

try:
    print('Starting...')
    print('=' * 60)
    # Simulate some work
    for i in range(5):
        print(f'Step {i}')
    print('=' * 60)
    print('Done!')
except KeyboardInterrupt:
    print()
    print('Cancelled by user')
    sys.exit(1)
except Exception as e:
    print()
    print(f'FATAL ERROR: {e}')
    traceback.print_exc()
    sys.exit(1)
"@

Write-Host "Running exception test..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
