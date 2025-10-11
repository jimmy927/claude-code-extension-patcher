#!/usr/bin/env pwsh

Write-Host "TEST: Capture patcher output and examine for control chars"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Read Python file
$PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

# Build sys.argv with -y flag
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()
$SysArgv = "['$WslScriptPath', '-y']"

# Create wrapper
$Wrapper = @"
import sys
sys.argv = $SysArgv
# Execute the actual script below:
$PythonCode
"@

Write-Host "Running patcher and capturing output..."
Write-Host ""

# Capture output
$Output = $Wrapper | wsl python3 -u - 2>&1

# Display output
$Output

Write-Host ""
Write-Host "---"
Write-Host ""
Write-Host "Checking for control characters..."
Write-Host ""

# Check for control chars
$OutputStr = $Output -join "`n"
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($OutputStr)

$ControlChars = @()
for ($i = 0; $i -lt $Bytes.Length; $i++) {
    $b = $Bytes[$i]
    # Control characters are 0-31 (except newline 10, carriage return 13, tab 9)
    if ($b -lt 32 -and $b -ne 10 -and $b -ne 13 -and $b -ne 9) {
        $ControlChars += "Byte $i : 0x$($b.ToString('X2')) (decimal $b)"
    }
}

if ($ControlChars.Count -gt 0) {
    Write-Host "FOUND CONTROL CHARACTERS:"
    $ControlChars | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "No unexpected control characters found"
}

Write-Host ""
Write-Host "Done - check if prompt corrupted"
