#!/usr/bin/env pwsh

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

Write-Host "TEST: Running ultra-yolo-patcher.py via STDIN (piped to python3 -)"
Write-Host ""

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Create wrapper that sets sys.argv
$WslScriptPath = "/mnt/c/Users/jimmy/src/claude-code-extension-patchger/ultra-yolo-patcher.py"
$Wrapper = @"
import sys
sys.argv = ['$WslScriptPath', '--help']
# Execute the actual script below:
$PythonCode
"@

Write-Host "Running Python via stdin with --help..."
Write-Host ""

# Pipe to WSL python3 stdin - NO ESCAPING NEEDED!
$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check prompt for corruption"
