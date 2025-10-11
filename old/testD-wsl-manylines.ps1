#!/usr/bin/env pwsh
Write-Host "TEST D: wsl with many lines (50 lines)"
wsl python3 -c "for i in range(50): print('='*60)"
Write-Host "Done with TEST D"
