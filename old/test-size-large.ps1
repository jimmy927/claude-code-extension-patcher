#!/usr/bin/env pwsh

Write-Host "TEST: Pipe 10000 lines of Python code"

$Code = "print('test')`n" * 10000

$Code | wsl python3 -u - 2>&1 | Out-Null

Write-Host "Done - check if prompt corrupted"
