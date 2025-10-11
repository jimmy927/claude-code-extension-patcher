#!/usr/bin/env pwsh

Write-Host "TEST: Pipe test-minimal.py via stdin with NO args (actual execution)"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MinimalScript = Join-Path $ScriptDir "test-minimal.py"
$PythonCode = Get-Content $MinimalScript -Raw -Encoding UTF8

$Wrapper = @"
import sys
sys.argv = ['test-minimal.py']
$PythonCode
"@

Write-Host "Running test-minimal.py (no --help, actual execution)..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
