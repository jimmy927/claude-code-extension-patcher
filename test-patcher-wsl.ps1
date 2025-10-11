#!/usr/bin/env pwsh
# Test running the actual patcher in WSL

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Convert path
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "Testing: $WslScriptPath"
Write-Host ""

Write-Host "=== TEST 1: Run patcher with --help ==="
wsl.exe --exec python3 "$WslScriptPath" --help
Write-Host ""
Write-Host "After help - press enter"
Read-Host

Write-Host ""
Write-Host "=== TEST 2: Run patcher with --help (captured) ==="
$output = wsl.exe --exec python3 "$WslScriptPath" --help 2>&1
$output | ForEach-Object { [Console]::WriteLine($_) }
Write-Host ""
Write-Host "After captured help - press enter"
Read-Host

Write-Host ""
Write-Host "=== All tests complete ==="
