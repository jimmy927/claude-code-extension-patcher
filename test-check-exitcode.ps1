#!/usr/bin/env pwsh

Write-Host "TEST: Check exit code from patcher with -y"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Build sys.argv with -y
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

$Wrapper | wsl python3 -u - 2>&1 | Out-Null

Write-Host ""
Write-Host "==================================="
Write-Host "Exit code: $LASTEXITCODE"
Write-Host "==================================="
Write-Host ""
Write-Host "Done - check if prompt corrupted"
