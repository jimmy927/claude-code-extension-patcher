#!/usr/bin/env pwsh
# Test script to debug WSL terminal corruption

Write-Host "=== TEST 1: Direct wsl command ==="
wsl echo "Hello from WSL"
Write-Host "After TEST 1 - press enter"
Read-Host

Write-Host ""
Write-Host "=== TEST 2: wsl bash -c ==="
wsl bash -c "echo 'Hello from bash'"
Write-Host "After TEST 2 - press enter"
Read-Host

Write-Host ""
Write-Host "=== TEST 3: wsl.exe --exec ==="
wsl.exe --exec echo "Hello from exec"
Write-Host "After TEST 3 - press enter"
Read-Host

Write-Host ""
Write-Host "=== TEST 4: wsl with captured output ==="
$output = wsl echo "Hello captured"
Write-Host $output
Write-Host "After TEST 4 - press enter"
Read-Host

Write-Host ""
Write-Host "=== TEST 5: wsl.exe --exec with captured output ==="
$output = wsl.exe --exec echo "Hello exec captured"
Write-Host $output
Write-Host "After TEST 5 - press enter"
Read-Host

Write-Host ""
Write-Host "=== TEST 6: Console.WriteLine with wsl ==="
$output = wsl echo "Hello console"
[Console]::WriteLine($output)
Write-Host "After TEST 6 - press enter"
Read-Host

Write-Host ""
Write-Host "=== TEST 7: Python in WSL ==="
wsl python3 -c "print('Hello from Python')"
Write-Host "After TEST 7 - press enter"
Read-Host

Write-Host ""
Write-Host "=== TEST 8: Python in WSL captured ==="
$output = wsl python3 -c "print('Hello from Python captured')"
[Console]::WriteLine($output)
Write-Host "After TEST 8 - press enter"
Read-Host

Write-Host ""
Write-Host "=== All tests complete ==="
Write-Host "Check if prompt is corrupted now"
