#!/usr/bin/env pwsh

Write-Host "TEST: Enter if __name__ block but do NOTHING"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Replace entire if __name__ block with just pass
$PythonCode = $PythonCode -replace @'
if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print()
        print("Cancelled by user")
        sys.exit(1)
    except Exception as e:
        print()
        print(f"FATAL ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
'@, @'
if __name__ == '__main__':
    pass
'@

$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

$Wrapper = @"
import sys
sys.argv = $SysArgv
$PythonCode
"@

Write-Host "Running patcher - if __name__ block is just 'pass'..."
Write-Host ""

$Wrapper | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
