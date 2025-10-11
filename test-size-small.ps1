#!/usr/bin/env pwsh

Write-Host "TEST: Pipe 100 lines of Python code"

$Code = "print('test')`n" * 100

$Code | wsl python3 -u - 2>&1 | Out-Null

Write-Host "Done - check if prompt corrupted"
