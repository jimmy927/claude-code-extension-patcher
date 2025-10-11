#!/usr/bin/env pwsh

Write-Host "TEST: Pipe large text to WSL bash"
$LargeText = "x" * 100000
$LargeText | wsl bash -c "cat > /dev/null"
Write-Host "Done - check if prompt corrupted"
