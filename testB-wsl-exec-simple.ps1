#!/usr/bin/env pwsh
Write-Host "TEST B: wsl.exe --exec (3 lines)"
wsl.exe --exec python3 -c "print('=' * 60); print('Hello'); print('=' * 60)"
Write-Host "Done with TEST B"
