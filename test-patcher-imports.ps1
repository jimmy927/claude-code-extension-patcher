#!/usr/bin/env pwsh

Write-Host "TEST: Test patcher's exact imports"
Write-Host ""

$Code = @"
import os
import sys
import shutil
import re
import argparse
from pathlib import Path
from typing import List, Tuple

sys.argv = ['test.py', '-y']

print('All imports successful')
print(f'sys.argv: {sys.argv}')
print(f'Python version: {sys.version}')
print(f'Platform: {sys.platform}')
print(f'Home: {Path.home()}')
print()

# Parse args like the patcher
parser = argparse.ArgumentParser(description='Test')
parser.add_argument('-y', '--yes', action='store_true')
args = parser.parse_args()

print(f'Args parsed: yes={args.yes}')
print()
print('Done!')
"@

Write-Host "Running imports test..."
Write-Host ""

$Code | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
