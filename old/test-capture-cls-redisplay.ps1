#!/usr/bin/env pwsh

Write-Host "TEST: Capture output, cls, then redisplay"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

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

# Capture ALL output
$Output = $Wrapper | wsl python3 -u - 2>&1

# Clear screen to reset terminal
cls

# Redisplay captured output
Write-Host "WSL Patcher Output:"
Write-Host "=" * 60
$Output | ForEach-Object { Write-Host $_ }
Write-Host "=" * 60
Write-Host ""

Write-Host "Done - check if prompt is NOW OK"
