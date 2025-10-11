#!/usr/bin/env pwsh

Write-Host "TEST: Pipe large text to WSL python3 stdin"
$LargeText = "x" * 100000
$LargeText | wsl python3 -c "import sys; sys.stdin.read()"
Write-Host "Done - check if prompt corrupted"
