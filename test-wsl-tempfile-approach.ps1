#!/usr/bin/env pwsh

Write-Host "TEST: Write wrapper to WSL temp, run from WSL filesystem"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

# Create wrapper
$Wrapper = @"
import sys
sys.argv = $SysArgv
$PythonCode
"@

# Write wrapper to WSL temp file
$TempFile = "/tmp/patcher-$(Get-Random).py"
Write-Host "Writing wrapper to WSL temp: $TempFile"
[System.IO.File]::WriteAllText("$env:TEMP\patcher-temp.py", $Wrapper)
$WinTempPath = "$env:TEMP\patcher-temp.py"
$WslTempPath = (wsl wslpath -u "$WinTempPath").Trim()
wsl cp "$WslTempPath" "$TempFile"
Remove-Item "$WinTempPath"

Write-Host "Running from WSL filesystem..."
Write-Host ""

# Run from WSL filesystem
wsl python3 -u "$TempFile"

Write-Host ""
Write-Host "Cleaning up..."
wsl rm -f "$TempFile"

Write-Host "Done - check if prompt corrupted"
