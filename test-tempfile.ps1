#!/usr/bin/env pwsh

Write-Host "TEST: Write wrapper to temp file, run from WSL filesystem"
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

# Write to WSL temp file
$TempScript = "/tmp/patcher-wrapper-$(Get-Random).py"
Write-Host "Writing wrapper to: $TempScript"
$Wrapper | wsl bash -c "cat > '$TempScript'"

Write-Host "Running from WSL temp file..."
Write-Host ""

# Run from WSL filesystem (not piped!)
wsl python3 -u "$TempScript"

Write-Host ""
Write-Host "Cleaning up..."
wsl rm -f "$TempScript"

Write-Host "Done - check if prompt corrupted"
