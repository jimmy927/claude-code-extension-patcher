#!/usr/bin/env pwsh

Write-Host "TEST: Use bash heredoc instead of piping"
Write-Host ""

$Code = @"
import sys
print('Testing heredoc approach')
for i in range(10):
    print(f'Line {i}')
print('Done!')
"@

# Escape for bash
$CodeEscaped = $Code -replace "'", "'\\''"

Write-Host "Running with bash heredoc..."
Write-Host ""

wsl bash -c "python3 -u <<'HEREDOC'
$Code
HEREDOC"

Write-Host ""
Write-Host "Done - check if prompt corrupted"
