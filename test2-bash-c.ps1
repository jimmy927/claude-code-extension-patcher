#!/usr/bin/env pwsh
# TEST 2: wsl bash -c

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "TEST 2: wsl bash -c"
wsl bash -c "python3 '$WslScriptPath' --help"
Write-Host "Done - check prompt after script exits"
