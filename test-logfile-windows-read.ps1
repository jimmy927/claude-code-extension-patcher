#!/usr/bin/env pwsh

Write-Host "TEST: Run patcher with log, read from Windows (not WSL)"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Build sys.argv with -y
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

# Use Windows temp file instead of WSL temp
$WinLogFile = Join-Path $env:TEMP "patcher-wsl-output.log"
$EscapedLogPath = $WinLogFile -replace '\\', '\\'
$WslLogFile = (wsl wslpath -u `"$EscapedLogPath`" 2>&1 | Select-Object -First 1)
if ($WslLogFile) { $WslLogFile = $WslLogFile.Trim() }

# Remove old log if exists
if (Test-Path $WinLogFile) { Remove-Item $WinLogFile }

# Wrapper that redirects stdout/stderr to file
$Wrapper = @"
import sys
sys.argv = $SysArgv

# Redirect all output to log file
log = open('$WslLogFile', 'w', encoding='utf-8')
sys.stdout = log
sys.stderr = log

# Execute patcher
$PythonCode

# Close log
log.close()
"@

Write-Host "Running patcher (output to Windows temp file)..."
Write-Host ""

# Run patcher - no output to terminal!
$Wrapper | wsl python3 -u - 2>&1 | Out-Null

Write-Host "Patcher finished. Exit code: $LASTEXITCODE"
Write-Host ""
Write-Host "Reading log file from Windows..."
Write-Host ""

# Read from Windows filesystem - NO WSL involved!
if (Test-Path $WinLogFile) {
    Get-Content $WinLogFile
    Write-Host ""
    Remove-Item $WinLogFile
} else {
    Write-Host "ERROR: Log file not found!"
}

Write-Host "Done - check if prompt corrupted"
