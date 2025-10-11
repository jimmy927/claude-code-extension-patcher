#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Claude Code Ultra YOLO Patcher - Dual Mode (Windows + WSL)

.DESCRIPTION
    Runs the Python patcher on both Windows and WSL installations.

.PARAMETER undo
    Restore original files from backups

.PARAMETER repatch
    Undo then patch (useful after updates)

.PARAMETER yes
    Skip all confirmation prompts

.PARAMETER skipWsl
    Skip WSL patching (Windows only)

.EXAMPLE
    .\ultra-yolo-patcher-dual.ps1
    Apply patches to both Windows and WSL with confirmation

.EXAMPLE
    .\ultra-yolo-patcher-dual.ps1 -yes
    Apply patches without prompts

.EXAMPLE
    .\ultra-yolo-patcher-dual.ps1 -undo -yes
    Restore original files on both Windows and WSL

.EXAMPLE
    .\ultra-yolo-patcher-dual.ps1 -repatch -yes
    Undo + patch on both Windows and WSL

.EXAMPLE
    .\ultra-yolo-patcher-dual.ps1 -skipWsl
    Apply patches only to Windows (skip WSL)
#>

param(
    [switch]$undo,
    [switch]$repatch,
    [switch]$yes,
    [switch]$skipWsl
)

$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"

# Check if Python script exists
if (-not (Test-Path $PythonScript)) {
    Write-Host "ERROR: ultra-yolo-patcher.py not found!" -ForegroundColor Red
    Write-Host "Expected location: $PythonScript" -ForegroundColor Red
    exit 1
}

# Build arguments
$PythonArgs = @()
if ($undo) { $PythonArgs += "--undo" }
if ($repatch) { $PythonArgs += "--repatch" }
if ($yes) { $PythonArgs += "-y" }

$ArgString = $PythonArgs -join " "

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Claude Code Ultra YOLO Patcher - DUAL MODE" -ForegroundColor Cyan
Write-Host "  Windows + WSL Python Patcher" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# WINDOWS PATCHING
# ============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  [1/2] PATCHING WINDOWS INSTALLATION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Try python3 first, then python
    $PythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
    if (-not $PythonCmd) {
        $PythonCmd = Get-Command python -ErrorAction SilentlyContinue
    }

    if (-not $PythonCmd) {
        Write-Host "ERROR: Python not found in PATH!" -ForegroundColor Red
        Write-Host "Please install Python 3.6+ from python.org" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "Using Python: $($PythonCmd.Source)" -ForegroundColor Green
    Write-Host ""

    # Run Python patcher for Windows
    & $PythonCmd.Source $PythonScript @PythonArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: Windows patching failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host ""
    Write-Host "[SUCCESS] Windows patching completed!" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "ERROR: Windows patching failed: $_" -ForegroundColor Red
    exit 1
}

# ============================================================================
# WSL PATCHING
# ============================================================================
if (-not $skipWsl) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  [2/2] PATCHING WSL INSTALLATION" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    # Check if WSL is available
    $WslAvailable = $false
    try {
        $WslCheck = wsl --status 2>&1
        $WslAvailable = $LASTEXITCODE -eq 0
    } catch {
        $WslAvailable = $false
    }

    if (-not $WslAvailable) {
        Write-Host "WSL not detected - skipping WSL patching" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "WSL detected - running patcher in WSL..." -ForegroundColor Green
        Write-Host ""

        # Convert Windows path to WSL path using wslpath (the proper Windows tool)
        # Need to escape the path for WSL shell
        $EscapedPath = $PythonScript -replace '\\', '\\'
        $WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1)

        if ([string]::IsNullOrWhiteSpace($WslScriptPath) -or $WslScriptPath -like '*error*') {
            Write-Host "ERROR: Failed to convert Windows path to WSL path" -ForegroundColor Red
            Write-Host "Windows path: $PythonScript" -ForegroundColor Yellow
            Write-Host "wslpath output: $WslScriptPath" -ForegroundColor Yellow
            Write-Host "Please ensure WSL is properly configured" -ForegroundColor Yellow
            exit 1
        }

        $WslScriptPath = $WslScriptPath.Trim()
        Write-Host "Windows path: $PythonScript" -ForegroundColor Gray
        Write-Host "WSL path:     $WslScriptPath" -ForegroundColor Green
        Write-Host ""

        # Run Python patcher in WSL
        if ($ArgString) {
            wsl python3 "$WslScriptPath" $ArgString
        } else {
            wsl python3 "$WslScriptPath"
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "WARNING: WSL patching failed with exit code $LASTEXITCODE" -ForegroundColor Yellow
            Write-Host "Windows installation was patched successfully." -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "[SUCCESS] WSL patching completed!" -ForegroundColor Green
            Write-Host ""
        }
    }
} else {
    Write-Host ""
    Write-Host "Skipping WSL patching (--skipWsl specified)" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# FINAL SUMMARY
# ============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  FINAL SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if (-not $undo) {
    Write-Host "IMPORTANT: RESTART Cursor/VSCode completely to apply changes!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Log files:" -ForegroundColor Cyan
    Write-Host "  Windows: $env:TEMP\claude-code-yolo.log" -ForegroundColor White
    if (-not $skipWsl -and $WslAvailable) {
        Write-Host "  WSL:     /tmp/claude-code-yolo.log" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "View Windows logs:" -ForegroundColor Yellow
    Write-Host "  Get-Content `"$env:TEMP\claude-code-yolo.log`" -Wait -Tail 20" -ForegroundColor White
    if (-not $skipWsl -and $WslAvailable) {
        Write-Host ""
        Write-Host "View WSL logs:" -ForegroundColor Yellow
        Write-Host "  wsl tail -f /tmp/claude-code-yolo.log" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
Write-Host ""
