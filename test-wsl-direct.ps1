#!/usr/bin/env pwsh

Write-Host "TEST: Run ultra-yolo-patcher.py DIRECTLY in WSL (no stdin)"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "Running: wsl python3 '$WslScriptPath' -y"
Write-Host ""

# Run DIRECTLY (no stdin piping)
wsl python3 "$WslScriptPath" -y

Write-Host ""
Write-Host "Done - check prompt"
