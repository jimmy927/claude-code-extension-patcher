#!/usr/bin/env pwsh

Write-Host "TEST: Run patcher and reset console from PowerShell"
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

Write-Host "Running patcher..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Resetting console..."

# Reset console buffer and cursor
[Console]::Clear()
[Console]::CursorLeft = 0
[Console]::CursorTop = 0
[Console]::Title = "PowerShell"

# Force redraw
$Host.UI.RawUI.WindowTitle = $Host.UI.RawUI.WindowTitle

Write-Host "Done - check if prompt corrupted"
