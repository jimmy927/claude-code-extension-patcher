#!/usr/bin/env pwsh

Write-Host "TEST: Run patcher and reset terminal after"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Build sys.argv with -y flag
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

# Create wrapper that resets terminal at the end
$Wrapper = @"
import sys
import os
sys.argv = $SysArgv
# Execute the actual script below:
$PythonCode
# Reset terminal state after execution
os.system('stty sane 2>/dev/null || true')
"@

Write-Host "Running patcher with terminal reset..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
