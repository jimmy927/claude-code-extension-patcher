#!/usr/bin/env pwsh

Write-Host "TEST: Run patcher, then clear screen"
Write-Host ""

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

Write-Host "Running patcher..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Clearing screen to fix corruption..."
Start-Sleep -Milliseconds 100
cls

Write-Host "Done - check if prompt is NOW OK after cls"
