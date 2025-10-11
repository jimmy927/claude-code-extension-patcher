#!/usr/bin/env pwsh

Write-Host "TEST: Patcher but exit BEFORE finding files"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Inject early exit in find_extension_files() at the start
$PythonCode = $PythonCode -replace 'def find_extension_files\(\) -> List\[Path\]:', @'
def find_extension_files() -> List[Path]:
    """Find all Claude Code extension JavaScript files"""
    print("Early exit - NOT finding files")
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

Write-Host "Running patcher with early exit..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
