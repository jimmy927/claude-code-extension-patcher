#!/usr/bin/env pwsh

Write-Host "TEST: Exit BEFORE argparse in main()"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Inject exit at the very start of main()
$PythonCode = $PythonCode -replace 'def main\(\):', @'
def main():
    print("Inside main() - exiting immediately")
    import sys
    sys.exit(0)
    # Original code below (never executed):
'@

$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

$Wrapper = @"
import sys
sys.argv = $SysArgv
$PythonCode
"@

Write-Host "Running patcher - exit at start of main()..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
