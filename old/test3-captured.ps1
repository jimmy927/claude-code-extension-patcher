#!/usr/bin/env pwsh
# TEST 3: Captured and printed

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "TEST 3: Captured then Write-Host"
$output = wsl.exe --exec python3 "$WslScriptPath" --help 2>&1
$output | ForEach-Object { Write-Host $_ }
Write-Host "Done - check prompt after script exits"
