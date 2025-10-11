#!/usr/bin/env pwsh

Write-Host "TEST: Just argparse, exit immediately"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Inject exit right after argparse
$PythonCode = $PythonCode -replace 'args = parser\.parse_args\(\)', @'
args = parser.parse_args()
    print("Argparse done - exiting")
    import sys
    sys.exit(0)
'@

$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

$Wrapper = @"
import sys
sys.argv = $SysArgv
$PythonCode
"@

Write-Host "Running patcher - exit after argparse..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
