#!/usr/bin/env pwsh

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SimpleScript = Join-Path $ScriptDir "test-simple-output.py"

Write-Host "TEST: Simple Python via STDIN"
Write-Host ""

# Read the Python file
$PythonCode = Get-Content $SimpleScript -Raw -Encoding UTF8

# Create wrapper
$Wrapper = @"
import sys
sys.argv = ['test-simple-output.py']
# Execute script:
$PythonCode
"@

# Pipe to WSL python3 stdin
$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check prompt"
