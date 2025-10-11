#!/usr/bin/env pwsh

Write-Host "TEST: Load everything but DON'T enter main() at all"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Replace the if __name__ block to NOT call main
$PythonCode = $PythonCode -replace @'
if __name__ == '__main__':
    try:
        main()
'@, @'
if __name__ == '__main__':
    print("NOT calling main() - just exiting")
    import sys
    sys.exit(0)
    try:
        main()
'@

$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

$Wrapper = @"
import sys
sys.argv = $SysArgv
$PythonCode
"@

Write-Host "Running patcher - NOT calling main()..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
