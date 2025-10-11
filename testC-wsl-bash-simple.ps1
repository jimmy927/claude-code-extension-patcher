#!/usr/bin/env pwsh
Write-Host "TEST C: wsl bash -c (3 lines)"
wsl bash -c "python3 -c \"print('=' * 60); print('Hello'); print('=' * 60)\""
Write-Host "Done with TEST C"
