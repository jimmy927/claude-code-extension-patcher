#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Claude Code Ultra YOLO Patcher - Dual Mode (Windows + WSL) - V2 with Terminal Fix
#>

[CmdletBinding()]
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
    Write-Host "ERROR: ultra-yolo-patcher.py not found!"
    Write-Host "Expected location: $PythonScript"
    exit 1
}

# Build arguments
$PythonArgs = @()
if ($undo) { $PythonArgs += "--undo" }
if ($repatch) { $PythonArgs += "--repatch" }
if ($yes) { $PythonArgs += "-y" }

Write-Host ""
Write-Host "============================================================"
Write-Host "  Claude Code Ultra YOLO Patcher - DUAL MODE"
Write-Host "  Windows + WSL Python Patcher"
Write-Host "============================================================"
Write-Host ""

# ============================================================================
# WINDOWS PATCHING
# ============================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host "  [1/2] PATCHING WINDOWS INSTALLATION"
Write-Host "============================================================"
Write-Host ""

try {
    # Try python3 first, then python
    $PythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
    if (-not $PythonCmd) {
        $PythonCmd = Get-Command python -ErrorAction SilentlyContinue
    }

    if (-not $PythonCmd) {
        Write-Host "ERROR: Python not found in PATH!"
        Write-Host "Please install Python 3.6+ from python.org"
        exit 1
    }

    Write-Host "Using Python: $($PythonCmd.Source)"
    Write-Host ""

    # Run Python patcher for Windows
    & $PythonCmd.Source $PythonScript @PythonArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: Windows patching failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }

    Write-Host ""
    Write-Host "[SUCCESS] Windows patching completed!"
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "ERROR: Windows patching failed: $_"
    exit 1
}

# ============================================================================
# WSL PATCHING
# ============================================================================
if (-not $skipWsl) {
    Write-Host ""
    Write-Host "============================================================"
    Write-Host "  [2/2] PATCHING WSL INSTALLATION"
    Write-Host "============================================================"
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
        Write-Host "WSL not detected - skipping WSL patching"
        Write-Host ""
    } else {
        Write-Host "WSL detected - running patcher in WSL..."
        Write-Host ""

        # Convert Windows path to WSL path for sys.argv[0]
        $EscapedPath = $PythonScript -replace '\\', '\\'
        $WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1)

        if ([string]::IsNullOrWhiteSpace($WslScriptPath) -or $WslScriptPath -like '*error*') {
            Write-Host "ERROR: Failed to convert Windows path to WSL path"
            Write-Host "Windows path: $PythonScript"
            Write-Host "wslpath output: $WslScriptPath"
            Write-Host "Please ensure WSL is properly configured"
            exit 1
        }

        $WslScriptPath = $WslScriptPath.Trim()
        Write-Host "Windows path: $PythonScript"
        Write-Host "WSL path:     $WslScriptPath"
        Write-Host ""

        # Read the Python script
        Write-Host "Reading Python script..."
        $PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

        # Build sys.argv
        $SysArgv = "['$WslScriptPath'"
        foreach ($arg in $PythonArgs) {
            $SysArgv += ", '$arg'"
        }
        $SysArgv += "]"

        # Create clean wrapper with sys.argv
        $Wrapper = @"
import sys
sys.argv = $SysArgv
# Execute script:
$PythonCode
"@

        Write-Host "Running patcher in WSL..."
        Write-Host ""

        # ALTERNATIVE APPROACH: Capture output and replay it
        # This gives PowerShell full control over output
        $tempOutput = [System.Collections.ArrayList]::new()

        & {
            $Wrapper | wsl -- python3 -u - 2>&1
        } | ForEach-Object {
            Write-Host $_
        }

        # Check exit code
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "ERROR: WSL patching failed with exit code $LASTEXITCODE"
            exit $LASTEXITCODE
        }

        Write-Host ""
        Write-Host "[SUCCESS] WSL patching completed!"
        Write-Host ""
    }
} else {
    Write-Host ""
    Write-Host "Skipping WSL patching (--skipWsl specified)"
    Write-Host ""
}

# ============================================================================
# FINAL SUMMARY
# ============================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host "  FINAL SUMMARY"
Write-Host "============================================================"
Write-Host ""

if (-not $undo) {
    Write-Host "IMPORTANT: RESTART Cursor/VSCode completely to apply changes!"
    Write-Host ""
    Write-Host "Log files:"
    Write-Host "  Windows: $env:TEMP\claude-code-yolo.log"
    if (-not $skipWsl -and $WslAvailable) {
        Write-Host "  WSL:     /tmp/claude-code-yolo.log"
    }
    Write-Host ""
    Write-Host "View Windows logs:"
    Write-Host "  Get-Content `"$env:TEMP\claude-code-yolo.log`" -Wait -Tail 20"
    if (-not $skipWsl -and $WslAvailable) {
        Write-Host ""
        Write-Host "View WSL logs:"
        Write-Host "  wsl tail -f /tmp/claude-code-yolo.log"
    }
}

Write-Host ""
Write-Host "Done!"
Write-Host ""
