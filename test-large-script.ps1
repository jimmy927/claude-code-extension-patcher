#!/usr/bin/env pwsh

Write-Host "TEST: Large Python script via stdin (397 lines like the patcher)"
Write-Host ""

# Create a large Python script similar in size to patcher
$LargeScript = @"
import sys
import argparse

sys.argv = ['test.py', '-y']

# Lots of comments and functions to make it ~400 lines like the patcher
"@

# Add many dummy functions to reach ~400 lines
for ($i = 1; $i -le 50; $i++) {
    $LargeScript += @"

def dummy_function_$i():
    '''Dummy function $i'''
    x = 1 + 1
    y = x * 2
    z = y + 3
    return z

"@
}

$LargeScript += @"

# Main execution
print('=' * 60)
print('Large script test')
print('=' * 60)
print()
print('Doing some work...')
for i in range(10):
    result = dummy_function_1()
    print(f'Step {i}: result = {result}')
print()
print('Done!')
"@

Write-Host "Script has $($LargeScript.Split("`n").Count) lines"
Write-Host "Running large script..."
Write-Host ""

$LargeScript | wsl python3 -u -

Write-Host ""
Write-Host "Done - check if prompt corrupted"
