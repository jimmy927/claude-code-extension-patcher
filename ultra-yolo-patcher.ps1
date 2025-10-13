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
    .\ultra-yolo-patcher.ps1
    Apply patches to both Windows and WSL with confirmation

.EXAMPLE
    .\ultra-yolo-patcher.ps1 -yes
    Apply patches without prompts

.EXAMPLE
    .\ultra-yolo-patcher.ps1 -undo -yes
    Restore original files on both Windows and WSL

.EXAMPLE
    .\ultra-yolo-patcher.ps1 -repatch -yes
    Undo + patch on both Windows and WSL

.EXAMPLE
    .\ultra-yolo-patcher.ps1 -skipWsl
    Apply patches only to Windows (skip WSL)
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
    [Console]::WriteLine("ERROR: ultra-yolo-patcher.py not found!")
    [Console]::WriteLine("Expected location: $PythonScript")
    exit 1
}

# Build arguments for Windows
$PythonArgs = @()
if ($undo) { $PythonArgs += "--undo" }
if ($repatch) { $PythonArgs += "--repatch" }
if ($yes) { $PythonArgs += "-y" }

# Build arguments for WSL (always add -y since stdin is used for piping)
$WslArgs = @()
if ($undo) { $WslArgs += "--undo" }
if ($repatch) { $WslArgs += "--repatch" }
$WslArgs += "-y"  # Always skip prompts in WSL (stdin unavailable)

$ArgString = $PythonArgs -join " "

[Console]::WriteLine("Claude Code YOLO Patcher - Dual Mode (Windows + WSL)")
[Console]::WriteLine("")
[Console]::WriteLine("[1/2] Windows...")

try {
    # Try python first (standard on Windows), then python3 (Linux/macOS)
    $PythonCmd = $null

    # Test python command
    try {
        $testPython = Get-Command python -ErrorAction Stop
        $null = & $testPython.Source --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $PythonCmd = $testPython
            [Console]::WriteLine("Using: python (version $(& $testPython.Source --version 2>&1))")
        }
    } catch {
        # python not found or failed, continue
    }

    # If python failed, try python3
    if (-not $PythonCmd) {
        try {
            $testPython3 = Get-Command python3 -ErrorAction Stop
            $null = & $testPython3.Source --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                $PythonCmd = $testPython3
                [Console]::WriteLine("Using: python3 (version $(& $testPython3.Source --version 2>&1))")
            }
        } catch {
            # python3 not found or failed
        }
    }

    if (-not $PythonCmd) {
        [Console]::WriteLine("ERROR: Python not found in PATH!")
        [Console]::WriteLine("Please install Python 3.6+ from python.org")
        exit 1
    }

    # Run Python patcher for Windows
    & $PythonCmd.Source $PythonScript @PythonArgs

    if ($LASTEXITCODE -ne 0) {
        [Console]::WriteLine("ERROR: Windows failed (exit code $LASTEXITCODE)")
        exit $LASTEXITCODE
    }

} catch {
    [Console]::WriteLine("ERROR: Windows patching failed: $_")
    exit 1
}

if (-not $skipWsl) {
    [Console]::WriteLine("")
    [Console]::WriteLine("[2/2] WSL...")

    # Check if WSL is available
    $WslAvailable = $false
    try {
        $WslCheck = wsl --status 2>&1
        $WslAvailable = $LASTEXITCODE -eq 0
    } catch {
        $WslAvailable = $false
    }

    if (-not $WslAvailable) {
        [Console]::WriteLine("WSL not detected - skipped")
    } else {
        # Convert Windows path to WSL path
        $EscapedPath = $PythonScript -replace '\\', '\\'
        $WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1)

        if ([string]::IsNullOrWhiteSpace($WslScriptPath) -or $WslScriptPath -like '*error*') {
            [Console]::WriteLine("ERROR: Failed to convert path to WSL")
            exit 1
        }

        $WslScriptPath = $WslScriptPath.Trim()
        $PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

        # Build sys.argv (use WslArgs which always includes -y)
        $SysArgv = "['$WslScriptPath'"
        foreach ($arg in $WslArgs) {
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

        # Run patcher
        $Wrapper | wsl -- python3 -u -

        # Reset console
        [Console]::Out.Flush()
        [Console]::Error.Flush()

        if ($LASTEXITCODE -ne 0) {
            [Console]::WriteLine("ERROR: WSL failed (exit code $LASTEXITCODE)")
            exit $LASTEXITCODE
        }
    }
}
