#!/usr/bin/env pwsh

Write-Host "TEST: Python script with input() that never executes"
Write-Host ""

$Code = @"
import sys

sys.argv = ['test.py', '--skip']

print('Starting test...')
print()

# input() function exists but is never called
if '--ask' in sys.argv:
    response = input('Press Enter to continue... ')
    print(f'You entered: {response}')
else:
    print('Skipping input (input() exists but not called)')

print()
print('Done!')
"@

Write-Host "Running input test..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
