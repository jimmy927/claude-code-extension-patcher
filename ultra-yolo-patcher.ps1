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

# Build arguments
$PythonArgs = @()
if ($undo) { $PythonArgs += "--undo" }
if ($repatch) { $PythonArgs += "--repatch" }
if ($yes) { $PythonArgs += "-y" }

$ArgString = $PythonArgs -join " "

[Console]::WriteLine("")
[Console]::WriteLine("============================================================")
[Console]::WriteLine("  Claude Code Ultra YOLO Patcher - DUAL MODE")
[Console]::WriteLine("  Windows + WSL Python Patcher")
[Console]::WriteLine("============================================================")
[Console]::WriteLine("")

# ============================================================================
# WINDOWS PATCHING
# ============================================================================
[Console]::WriteLine("")
[Console]::WriteLine("============================================================")
[Console]::WriteLine("  [1/2] PATCHING WINDOWS INSTALLATION")
[Console]::WriteLine("============================================================")
[Console]::WriteLine("")

try {
    # Try python3 first, then python
    $PythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
    if (-not $PythonCmd) {
        $PythonCmd = Get-Command python -ErrorAction SilentlyContinue
    }

    if (-not $PythonCmd) {
        [Console]::WriteLine("ERROR: Python not found in PATH!")
        [Console]::WriteLine("Please install Python 3.6+ from python.org")
        exit 1
    }

    [Console]::WriteLine("Using Python: $($PythonCmd.Source)")
    [Console]::WriteLine("")

    # Run Python patcher for Windows
    & $PythonCmd.Source $PythonScript @PythonArgs

    if ($LASTEXITCODE -ne 0) {
        [Console]::WriteLine("")
        [Console]::WriteLine("ERROR: Windows patching failed with exit code $LASTEXITCODE")
        exit $LASTEXITCODE
    }

    [Console]::WriteLine("")
    [Console]::WriteLine("[SUCCESS] Windows patching completed!")
    [Console]::WriteLine("")

} catch {
    [Console]::WriteLine("")
    [Console]::WriteLine("ERROR: Windows patching failed: $_")
    exit 1
}

# ============================================================================
# WSL PATCHING
# ============================================================================
if (-not $skipWsl) {
    [Console]::WriteLine("")
    [Console]::WriteLine("============================================================")
    [Console]::WriteLine("  [2/2] PATCHING WSL INSTALLATION")
    [Console]::WriteLine("============================================================")
    [Console]::WriteLine("")

    # Check if WSL is available
    $WslAvailable = $false
    try {
        $WslCheck = wsl --status 2>&1
        $WslAvailable = $LASTEXITCODE -eq 0
    } catch {
        $WslAvailable = $false
    }

    if (-not $WslAvailable) {
        [Console]::WriteLine("WSL not detected - skipping WSL patching")
        [Console]::WriteLine("")
    } else {
        [Console]::WriteLine("WSL detected - running patcher in WSL...")
        [Console]::WriteLine("")

        # Convert Windows path to WSL path for sys.argv[0]
        $EscapedPath = $PythonScript -replace '\\', '\\'
        $WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1)

        if ([string]::IsNullOrWhiteSpace($WslScriptPath) -or $WslScriptPath -like '*error*') {
            [Console]::WriteLine("ERROR: Failed to convert Windows path to WSL path")
            [Console]::WriteLine("Windows path: $PythonScript")
            [Console]::WriteLine("wslpath output: $WslScriptPath")
            [Console]::WriteLine("Please ensure WSL is properly configured")
            exit 1
        }

        $WslScriptPath = $WslScriptPath.Trim()
        [Console]::WriteLine("Windows path: $PythonScript")
        [Console]::WriteLine("WSL path:     $WslScriptPath")
        [Console]::WriteLine("")

        # WORKAROUND: Running Python .py files from WSL corrupts PowerShell terminal
        # SOLUTION: Pipe Python code via stdin to python3 (avoids file execution)
        [Console]::WriteLine("Reading Python script...")
        $PythonCode = Get-Content $PythonScript -Raw -Encoding UTF8

        # Build sys.argv
        $SysArgv = "['$WslScriptPath'"
        foreach ($arg in $PythonArgs) {
            $SysArgv += ", '$arg'"
        }
        $SysArgv += "]"

        # Create wrapper that sets sys.argv before executing script
        $Wrapper = @"
import sys
sys.argv = $SysArgv
# Execute the actual script below:
$PythonCode
"@

        [Console]::WriteLine("Running patcher in WSL (stdin mode to prevent terminal corruption)...")
        [Console]::WriteLine("")

        # Pipe to WSL python3 stdin - prevents terminal corruption!
        $Wrapper | wsl python3 -u -

        if ($LASTEXITCODE -ne 0) {
            [Console]::WriteLine("")
            [Console]::WriteLine("WARNING: WSL patching failed with exit code $LASTEXITCODE")
            [Console]::WriteLine("Windows installation was patched successfully.")
            [Console]::WriteLine("")
        } else {
            [Console]::WriteLine("")
            [Console]::WriteLine("[SUCCESS] WSL patching completed!")
            [Console]::WriteLine("")
        }
    }
} else {
    [Console]::WriteLine("")
    [Console]::WriteLine("Skipping WSL patching (--skipWsl specified)")
    [Console]::WriteLine("")
}

# ============================================================================
# FINAL SUMMARY
# ============================================================================
[Console]::WriteLine("")
[Console]::WriteLine("============================================================")
[Console]::WriteLine("  FINAL SUMMARY")
[Console]::WriteLine("============================================================")
[Console]::WriteLine("")

if (-not $undo) {
    [Console]::WriteLine("IMPORTANT: RESTART Cursor/VSCode completely to apply changes!")
    [Console]::WriteLine("")
    [Console]::WriteLine("Log files:")
    [Console]::WriteLine("  Windows: $env:TEMP\claude-code-yolo.log")
    if (-not $skipWsl -and $WslAvailable) {
        [Console]::WriteLine("  WSL:     /tmp/claude-code-yolo.log")
    }
    [Console]::WriteLine("")
    [Console]::WriteLine("View Windows logs:")
    [Console]::WriteLine("  Get-Content `"$env:TEMP\claude-code-yolo.log`" -Wait -Tail 20")
    if (-not $skipWsl -and $WslAvailable) {
        [Console]::WriteLine("")
        [Console]::WriteLine("View WSL logs:")
        [Console]::WriteLine("  wsl tail -f /tmp/claude-code-yolo.log")
    }
}

[Console]::WriteLine("")
[Console]::WriteLine("Done!")
[Console]::WriteLine("")
