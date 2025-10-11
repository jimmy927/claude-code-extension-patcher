#!/usr/bin/env pwsh

Write-Host "TEST: Pipe large Python code WITHOUT suppressing output"
$Code = @"
for i in range(100):
    print('Line ' + str(i))
"@
$Code | wsl python3 -u -
Write-Host ""
Write-Host "Done - check if prompt corrupted"
