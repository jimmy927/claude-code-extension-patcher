#!/usr/bin/env pwsh
# TEST 4: Full patcher run (lots of output)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "TEST 4: Full patcher run with -y"
wsl.exe --exec python3 "$WslScriptPath" -y
Write-Host "Done - check prompt after script exits"
