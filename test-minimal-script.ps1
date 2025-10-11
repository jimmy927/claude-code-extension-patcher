#!/usr/bin/env pwsh

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MinimalScript = Join-Path $ScriptDir "test-minimal.py"
$EscapedPath = $MinimalScript -replace '\\', '\\'
$WslMinimalPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "TEST: Minimal Python file with argparse + --help"
wsl.exe --exec python3 "$WslMinimalPath" --help
Write-Host "Done - check prompt"
