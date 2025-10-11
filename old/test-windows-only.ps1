#!/usr/bin/env pwsh

Write-Host "TEST: Running patcher on Windows ONLY (skip WSL)"
Write-Host ""

.\ultra-yolo-patcher.ps1 -repatch -y -skipWsl

Write-Host ""
Write-Host "Done - check if prompt is corrupted"
