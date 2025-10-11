#!/usr/bin/env pwsh

Write-Host "TEST: ultra-yolo-patcher.py with CAPTURED OUTPUT (prevents corruption)"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

$Wrapper = @"
import sys
sys.argv = ['$WslScriptPath', '-y']
# Execute script:
$PythonCode
"@

Write-Host "Running with captured output..."
Write-Host ""

# Capture and replay output through Write-Host
& {
    $Wrapper | wsl -- python3 -u - 2>&1
} | ForEach-Object {
    Write-Host $_
}

Write-Host ""
Write-Host "Done - check prompt (should be CLEAN)"
