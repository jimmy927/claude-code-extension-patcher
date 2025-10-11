#!/usr/bin/env pwsh

Write-Host "TEST: First half of patcher code (lines 1-200)"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$AllLines = Get-Content $PythonScript -Encoding UTF8
$FirstHalf = $AllLines[0..199] -join "`n"

$Code = @"
$FirstHalf

# Stub main
if __name__ == '__main__':
    print('First half loaded successfully')
"@

Write-Host "Running first 200 lines..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
