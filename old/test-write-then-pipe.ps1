#!/usr/bin/env pwsh

Write-Host "TEST: Write wrapper to file first, then pipe to WSL"
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

# Write to temp file
$TempFile = "$env:TEMP\patcher-wrapper.py"
[System.IO.File]::WriteAllText($TempFile, $Wrapper, [System.Text.Encoding]::UTF8)

Write-Host "Piping from temp file..."
Write-Host ""

Get-Content $TempFile -Raw | wsl python3 -u -

Remove-Item $TempFile

Write-Host ""
Write-Host "Done - check if prompt corrupted"
