#!/usr/bin/env pwsh

Write-Host "TEST: argparse help via inline Python"
wsl python3 -c "import argparse; p=argparse.ArgumentParser(description='Test'); p.add_argument('--foo'); p.print_help()"
Write-Host "Done - check prompt"
