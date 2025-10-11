#!/usr/bin/env pwsh

Write-Host "TEST: Run patcher but suppress ALL output"
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

Write-Host "Running patcher (output suppressed)..."
Write-Host ""

$Output = $Wrapper | wsl python3 -u - 2>&1

Write-Host "Patcher finished. Exit code: $LASTEXITCODE"
Write-Host ""
Write-Host "Done - check if prompt corrupted (output was suppressed)"
