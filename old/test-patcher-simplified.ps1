#!/usr/bin/env pwsh

Write-Host "TEST: Simplified patcher (no actual patching, just find files)"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Build sys.argv with --help first
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "TEST 1: Patcher with --help"
$SysArgv1 = "['$WslScriptPath', '--help']"
$Wrapper1 = @"
import sys
sys.argv = $SysArgv1
$PythonCode
"@
$Wrapper1 | wsl python3 -u -
Write-Host "Exit code: $LASTEXITCODE"
Write-Host ""
Write-Host "Check prompt now - is it corrupted after --help?"
Write-Host ""
Read-Host "Press Enter to continue to test 2"
Write-Host ""

Write-Host "TEST 2: Patcher with -y"
$SysArgv2 = "['$WslScriptPath', '-y']"
$Wrapper2 = @"
import sys
sys.argv = $SysArgv2
$PythonCode
"@
$Wrapper2 | wsl python3 -u -
Write-Host "Exit code: $LASTEXITCODE"
Write-Host ""

Write-Host "Done - check if prompt corrupted after -y"
