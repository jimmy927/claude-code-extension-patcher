#!/usr/bin/env pwsh
# TEST 1: Direct wsl.exe --exec

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "TEST 1: wsl.exe --exec (direct with CR strip)"
$output = wsl.exe --exec python3 "$WslScriptPath" --help 2>&1
$output | ForEach-Object {
    $line = $_ -replace "`r", ""
    Write-Output $line
}
Write-Host "Done - check prompt after script exits"
