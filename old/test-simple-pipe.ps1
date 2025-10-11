#!/usr/bin/env pwsh

Write-Host "TEST 1: Pipe large text to WSL bash"
$LargeText = "x" * 100000
$LargeText | wsl bash -c "cat > /dev/null"
Write-Host "Done test 1"
Write-Host ""

Write-Host "TEST 2: Pipe large text to WSL python3"
$LargeText | wsl python3 -c "import sys; sys.stdin.read()"
Write-Host "Done test 2"
Write-Host ""

Write-Host "TEST 3: Pipe Python code to WSL python3"
$Code = "print('test')" * 1000
$Code | wsl python3 -u - 2>&1 | Out-Null
Write-Host "Done test 3"
Write-Host ""

Write-Host "Done - check if prompt corrupted"
