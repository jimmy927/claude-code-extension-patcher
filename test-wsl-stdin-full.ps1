#!/usr/bin/env pwsh

Write-Host "TEST: Running WSL patcher via STDIN (full execution with -y)"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Convert path
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "WSL path: $WslScriptPath"
Write-Host ""

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Build sys.argv with -y flag
$SysArgv = "['$WslScriptPath', '-y']"

# Create wrapper
$Wrapper = @"
import sys
sys.argv = $SysArgv
# Execute the actual script below:
$PythonCode
"@

Write-Host "Running patcher in WSL with -y flag (via stdin)..."
Write-Host ""

# Pipe to WSL
$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt is corrupted"
