#!/usr/bin/env pwsh

Write-Host "TEST: Run until after print_header, then exit"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Inject exit right after print_header in main_logic
$PythonCode = $PythonCode -replace 'print_header\("Claude Code Ultra YOLO Patcher\\n       100% NO PERMISSION PROMPTS MODE"\)', @'
print_header("Claude Code Ultra YOLO Patcher\n       100% NO PERMISSION PROMPTS MODE")
    import sys
    print("Header printed - exiting")
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

Write-Host "Running patcher - exit after header..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
