#!/usr/bin/env pwsh

Write-Host "TEST: Run patcher with PYTHONUNBUFFERED and non-interactive stdin"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Build sys.argv with -y flag
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

# Create wrapper
$Wrapper = @"
import sys
sys.argv = $SysArgv
# Execute the actual script below:
$PythonCode
"@

Write-Host "Running patcher with environment variables..."
Write-Host ""

# Pipe to WSL with TERM=dumb to prevent terminal manipulation
$Wrapper | wsl bash -c "PYTHONUNBUFFERED=1 TERM=dumb python3 -u -"

Write-Host ""
Write-Host "Done - check if prompt corrupted"
