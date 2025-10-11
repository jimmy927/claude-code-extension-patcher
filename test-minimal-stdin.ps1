#!/usr/bin/env pwsh

Write-Host "TEST: Piping test-minimal.py via STDIN"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MinimalScript = Join-Path $ScriptDir "test-minimal.py"

# Read the minimal Python file
$PythonCode = Get-Content $MinimalScript -Raw -Encoding UTF8

$Wrapper = @"
import sys
sys.argv = ['test-minimal.py', '--help']
# Execute the actual script below:
$PythonCode
"@

Write-Host "Piping test-minimal.py with --help via stdin..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
