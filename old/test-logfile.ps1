#!/usr/bin/env pwsh

Write-Host "TEST: Run patcher with ALL output redirected to log file"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Build sys.argv with -y
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

# Wrapper that redirects stdout/stderr to file
$LogFile = "/tmp/patcher-output-$((Get-Random)).log"
$Wrapper = @"
import sys
sys.argv = $SysArgv

# Redirect all output to log file
log = open('$LogFile', 'w', encoding='utf-8')
sys.stdout = log
sys.stderr = log

# Execute patcher
$PythonCode

# Close log
log.close()
"@

Write-Host "Running patcher (output to log file)..."
Write-Host ""

# Run patcher - no output to terminal!
$Wrapper | wsl python3 -u - 2>&1 | Out-Null

Write-Host "Patcher finished. Exit code: $LASTEXITCODE"
Write-Host ""
Write-Host "Reading log file..."
Write-Host ""

# Read and display log from Windows
wsl cat "$LogFile"

Write-Host ""
Write-Host "Cleaning up log..."
wsl rm -f "$LogFile"

Write-Host ""
Write-Host "Done - check if prompt corrupted"
