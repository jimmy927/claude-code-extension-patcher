#!/usr/bin/env pwsh

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MinimalScript = Join-Path $ScriptDir "test-minimal.py"

Write-Host "TEST: Minimal Python file with --foo bar (VIA STDIN)"
Write-Host ""

# Read the Python file
$PythonCode = Get-Content $MinimalScript -Raw -Encoding UTF8

# Create wrapper with sys.argv including --foo bar
$Wrapper = @"
import sys
sys.argv = ['test-minimal.py', '--foo', 'bar']
# Execute script:
$PythonCode
"@

# Pipe to WSL python3 stdin
$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check prompt"
