#!/usr/bin/env pwsh

Write-Host "TEST 1: wsl (direct command)"
wsl python3 -c "print('=' * 60); print('Hello'); print('=' * 60)"
Write-Host "Done with TEST 1"
Write-Host ""

Write-Host "TEST 2: wsl.exe --exec"
wsl.exe --exec python3 -c "print('=' * 60); print('Hello'); print('=' * 60)"
Write-Host "Done with TEST 2"
Write-Host ""

Write-Host "TEST 3: wsl bash -c"
wsl bash -c "python3 -c \"print('=' * 60); print('Hello'); print('=' * 60)\""
Write-Host "Done with TEST 3"
Write-Host ""

Write-Host "TEST 4: Many lines via wsl"
wsl python3 -c "for i in range(50): print('='*60)"
Write-Host "Done with TEST 4"
Write-Host ""

Write-Host "TEST 5: Many lines via wsl.exe --exec"
wsl.exe --exec python3 -c "for i in range(50): print('='*60)"
Write-Host "Done with TEST 5"
Write-Host ""

Write-Host "All tests complete - check prompt now"
