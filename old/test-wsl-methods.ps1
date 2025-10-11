#!/usr/bin/env pwsh
# Systematic test of different WSL invocation methods

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "Testing with: $WslScriptPath"
Write-Host ""
Write-Host "Run each test, then check if prompt is OK after script exits"
Write-Host "Press Ctrl+C to stop testing"
Write-Host ""

# TEST 1: Direct wsl.exe --exec
Write-Host "=== TEST 1: wsl.exe --exec (direct output) ==="
wsl.exe --exec python3 "$WslScriptPath" --help
Write-Host ""
Write-Host "Check prompt NOW - is it OK? (y/n)"
$response = Read-Host
if ($response -ne 'y') {
    Write-Host "TEST 1 CORRUPTS PROMPT!"
    exit
}

# TEST 2: With -u flag
Write-Host ""
Write-Host "=== TEST 2: wsl.exe --exec with -u flag ==="
wsl.exe --exec python3 -u "$WslScriptPath" --help
Write-Host ""
Write-Host "Check prompt NOW - is it OK? (y/n)"
$response = Read-Host
if ($response -ne 'y') {
    Write-Host "TEST 2 CORRUPTS PROMPT!"
    exit
}

# TEST 3: Using bash -c
Write-Host ""
Write-Host "=== TEST 3: wsl bash -c ==="
wsl bash -c "python3 '$WslScriptPath' --help"
Write-Host ""
Write-Host "Check prompt NOW - is it OK? (y/n)"
$response = Read-Host
if ($response -ne 'y') {
    Write-Host "TEST 3 CORRUPTS PROMPT!"
    exit
}

# TEST 4: Captured then printed
Write-Host ""
Write-Host "=== TEST 4: Captured with Write-Host ==="
$output = wsl.exe --exec python3 "$WslScriptPath" --help 2>&1
$output | ForEach-Object { Write-Host $_ }
Write-Host ""
Write-Host "Check prompt NOW - is it OK? (y/n)"
$response = Read-Host
if ($response -ne 'y') {
    Write-Host "TEST 4 CORRUPTS PROMPT!"
    exit
}

# TEST 5: Captured with Console.WriteLine
Write-Host ""
Write-Host "=== TEST 5: Captured with Console.WriteLine ==="
$output = wsl.exe --exec python3 "$WslScriptPath" --help 2>&1
$output | ForEach-Object { [Console]::WriteLine($_) }
Write-Host ""
Write-Host "Check prompt NOW - is it OK? (y/n)"
$response = Read-Host
if ($response -ne 'y') {
    Write-Host "TEST 5 CORRUPTS PROMPT!"
    exit
}

# TEST 6: Run actual patcher (full output)
Write-Host ""
Write-Host "=== TEST 6: Run actual patcher with -y (full run) ==="
wsl.exe --exec python3 "$WslScriptPath" -y
Write-Host ""
Write-Host "Check prompt NOW - is it OK? (y/n)"
$response = Read-Host
if ($response -ne 'y') {
    Write-Host "TEST 6 CORRUPTS PROMPT!"
    exit
}

Write-Host ""
Write-Host "=== ALL TESTS PASSED - NO CORRUPTION DETECTED ==="
