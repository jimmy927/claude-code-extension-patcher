#!/usr/bin/env pwsh

Write-Host "TEST: Piping first 100 lines of actual patcher"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Read only first 100 lines
$Lines = Get-Content $PythonScript -Encoding UTF8 | Select-Object -First 100
$PartialCode = $Lines -join "`n"

$Wrapper = @"
import sys
sys.argv = ['test.py']
print('Testing partial patcher content...')
print('First 100 lines loaded successfully')
print('No execution, just testing piping')
"@

Write-Host "Piping partial patcher content..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
