#!/usr/bin/env pwsh
Write-Host "TEST A: wsl (direct command, 3 lines)"
wsl python3 -c "print('=' * 60); print('Hello'); print('=' * 60)"
Write-Host "Done with TEST A"
