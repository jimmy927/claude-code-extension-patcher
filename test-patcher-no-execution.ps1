#!/usr/bin/env pwsh

Write-Host "TEST: Patcher code but DON'T call main()"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Remove the main execution
$PythonCode = $PythonCode -replace "if __name__ == '__main__':", "if False:"

$Wrapper = @"
import sys
sys.argv = ['test']
$PythonCode
print('Code loaded but main() NOT called')
"@

Write-Host "Loading patcher code without executing main()..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
