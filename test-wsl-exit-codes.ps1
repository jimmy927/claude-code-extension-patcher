#!/usr/bin/env pwsh

Write-Host "TEST 1: Exit with code 0 (success)"
$Code1 = @"
import sys
print('Test 1: Success')
print('=' * 60)
sys.exit(0)
"@
$Code1 | wsl python3 -u -
Write-Host "Exit code: $LASTEXITCODE"
Write-Host ""
Write-Host "---"
Write-Host ""

Write-Host "TEST 2: Exit with code 1 (error)"
$Code2 = @"
import sys
print('Test 2: Error')
print('=' * 60)
print('[ERROR] Something failed!')
sys.exit(1)
"@
$Code2 | wsl python3 -u -
Write-Host "Exit code: $LASTEXITCODE"
Write-Host ""
Write-Host "---"
Write-Host ""

Write-Host "TEST 3: KeyboardInterrupt exception"
$Code3 = @"
import sys
try:
    print('Test 3: Exception')
    print('=' * 60)
    raise KeyboardInterrupt()
except KeyboardInterrupt:
    print()
    print('Cancelled by user')
    sys.exit(1)
"@
$Code3 | wsl python3 -u -
Write-Host "Exit code: $LASTEXITCODE"
Write-Host ""

Write-Host "Done - check if prompt corrupted"
