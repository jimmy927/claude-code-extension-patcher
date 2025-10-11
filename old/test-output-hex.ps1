#!/usr/bin/env pwsh
# Check for escape codes in WSL Python output

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "Capturing output and checking for control characters..."
Write-Host ""

$output = wsl.exe --exec python3 "$WslScriptPath" --help 2>&1

# Check for control characters
$hasControlChars = $false
foreach ($line in $output) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($line)
    foreach ($byte in $bytes) {
        if ($byte -lt 32 -and $byte -ne 10 -and $byte -ne 13 -and $byte -ne 9) {
            Write-Host "Found control character: 0x$($byte.ToString('X2')) in line: $line"
            $hasControlChars = $true
        }
    }
}

if (-not $hasControlChars) {
    Write-Host "No unexpected control characters found"
}

Write-Host ""
Write-Host "Done"
