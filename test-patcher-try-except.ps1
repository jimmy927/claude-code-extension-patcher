#!/usr/bin/env pwsh

Write-Host "TEST: Enter try block but do nothing"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Replace try block content with just pass
$PythonCode = $PythonCode -replace @'
if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
'@, @'
if __name__ == '__main__':
    try:
        pass
    except KeyboardInterrupt:
'@

$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

$Wrapper = @"
import sys
sys.argv = $SysArgv
$PythonCode
"@

Write-Host "Running patcher - try block has just 'pass'..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
