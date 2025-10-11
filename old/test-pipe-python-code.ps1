#!/usr/bin/env pwsh

Write-Host "TEST: Pipe Python code to WSL python3 with output suppressed"
$Code = "print('test')" * 1000
$Code | wsl python3 -u - 2>&1 | Out-Null
Write-Host "Done - check if prompt corrupted"
