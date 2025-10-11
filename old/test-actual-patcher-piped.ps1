#!/usr/bin/env pwsh

Write-Host "TEST: Pipe ACTUAL patcher code (no log redirection)"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

$Wrapper = @"
import sys
sys.argv = $SysArgv
$PythonCode
"@

Write-Host "Piping actual patcher with -y flag..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
