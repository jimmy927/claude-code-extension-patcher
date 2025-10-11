#!/usr/bin/env pwsh

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "TEST: Run actual Python file (not argparse, just print)"
wsl python3 -c "print('=' * 60); print('Test'); print('=' * 60)"
Write-Host "Done test 1"
Write-Host ""

Write-Host "TEST: Run actual patcher file with --help"
wsl.exe --exec python3 "$WslScriptPath" --help
Write-Host "Done test 2 - check prompt"
