#!/usr/bin/env pwsh
# Test simple Python scripts to isolate the issue

Write-Host "=== TEST 1: Simple Python print ==="
$output = wsl.exe --exec python3 -c "print('='*60); print('Hello'); print('='*60)" 2>&1
$output | ForEach-Object { [Console]::WriteLine($_) }
Write-Host "Press enter after TEST 1"
Read-Host

Write-Host ""
Write-Host "=== TEST 2: Python with argparse ==="
$output = wsl.exe --exec python3 -c "import argparse; p=argparse.ArgumentParser(); p.add_argument('--test'); p.print_help()" 2>&1
$output | ForEach-Object { [Console]::WriteLine($_) }
Write-Host "Press enter after TEST 2"
Read-Host

Write-Host ""
Write-Host "=== TEST 3: Python with lots of output ==="
$output = wsl.exe --exec python3 -c "for i in range(50): print('='*60)" 2>&1
$output | ForEach-Object { [Console]::WriteLine($_) }
Write-Host "Press enter after TEST 3"
Read-Host

Write-Host ""
Write-Host "Done!"
