#!/usr/bin/env pwsh

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

Write-Host "TEST: Running ultra-yolo-patcher.py as INLINE code (via -c)"
Write-Host ""

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Escape single quotes for bash
$PythonCode = $PythonCode -replace "'", "'\\''"

# Build sys.argv with --help
$WslScriptPath = "/mnt/c/Users/jimmy/src/claude-code-extension-patchger/ultra-yolo-patcher.py"
$SysArgv = "['$WslScriptPath', '--help']"

# Inject sys.argv
$PythonCodeWithArgs = "import sys; sys.argv = $SysArgv`n$PythonCode"

Write-Host "Running Python inline with --help..."
Write-Host ""

wsl bash -c "python3 -u -c '$PythonCodeWithArgs'"

Write-Host ""
Write-Host "Done - check prompt for corruption"
