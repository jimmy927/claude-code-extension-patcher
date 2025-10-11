#!/usr/bin/env pwsh

Write-Host "TEST: Simulating patcher finding NO files and exiting with sys.exit(1)"
Write-Host ""

$Code = @"
import sys
import argparse

sys.argv = ['patcher.py', '-y']

parser = argparse.ArgumentParser(description='Test')
parser.add_argument('-y', '--yes', action='store_true')
args = parser.parse_args()

print()
print('=' * 60)
print('TEST PATCHER - NO FILES')
print('=' * 60)
print()
print('Searching...')
print()
print('[ERROR] No Claude Code extensions found!')
print()
sys.exit(1)
"@

Write-Host "Running patcher with sys.exit(1)..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Exit code: $LASTEXITCODE"
Write-Host "Done - check if prompt corrupted"
