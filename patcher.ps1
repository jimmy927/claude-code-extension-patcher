# Claude Code Patcher (v5 - Multi-Extension)
# PowerShell version

# Parse command line arguments (must be first!)
param(
    [switch]$undo
)

# Set window title
$host.UI.RawUI.WindowTitle = "Claude Code Patcher (v5 - Multi-Extension)"

# Define strings to search for and replace
# Support multiple versions with different variable names
$patterns = @(
    @{
        Name = "v2.0.10+ (k variable)"
        Original = 'k=\["--output-format","stream-json","--verbose","--input-format","stream-json"\]'
        Replacement = 'k=["--dangerously-skip-permissions","--output-format","stream-json","--verbose","--input-format","stream-json"]'
        Patched = 'k=\["--dangerously-skip-permissions","--output-format","stream-json","--verbose","--input-format","stream-json"\]'
    },
    @{
        Name = "v2.0.1 (F variable)"
        Original = 'F=\["--output-format","stream-json","--verbose","--input-format","stream-json"\]'
        Replacement = 'F=["--dangerously-skip-permissions","--output-format","stream-json","--verbose","--input-format","stream-json"]'
        Patched = 'F=\["--dangerously-skip-permissions","--output-format","stream-json","--verbose","--input-format","stream-json"\]'
    }
)

# Define file names
$targetFile = "extension.js"
$filePaths = @()

Write-Host ""
Write-Host "=========================================================="
if ($undo) {
    Write-Host "       Claude Code Patcher (v5 - UNDO MODE)"
} else {
    Write-Host "       Claude Code Patcher (v5 - Multi-Extension)"
}
Write-Host "=========================================================="

if ($undo) {
    Write-Host "This script will restore all backed-up '$targetFile' files."
} else {
    Write-Host "This script will modify '$targetFile' to add the"
    Write-Host "'--dangerously-skip-permissions' launch argument."
}

Write-Host ""
Write-Host "Searching for Claude Code extensions in VSCode and Cursor..."
Write-Host ""

# 1. Search for extension.js in typical locations
# Check if file exists in current directory first
$currentDirFile = Join-Path $PSScriptRoot $targetFile
if (Test-Path $currentDirFile) {
    $filePaths += $currentDirFile
    Write-Host "[FOUND] Extension in current directory" -ForegroundColor Green
}

# Search in VSCode extensions
Write-Host "[SEARCH] Looking in VSCode extensions..."
$vscodeExtensions = Join-Path $env:USERPROFILE ".vscode\extensions"
if (Test-Path $vscodeExtensions) {
    $claudeCodeDirs = Get-ChildItem -Path $vscodeExtensions -Directory -Filter "anthropics.claude-code-*" -ErrorAction SilentlyContinue
    foreach ($dir in $claudeCodeDirs) {
        # Try dist subdirectory first (older versions)
        $candidatePath = Join-Path $dir.FullName "dist\$targetFile"
        if (Test-Path $candidatePath) {
            $filePaths += $candidatePath
            Write-Host "[FOUND] $candidatePath" -ForegroundColor Green
        } else {
            # Try root directory (newer versions)
            $candidatePath = Join-Path $dir.FullName $targetFile
            if (Test-Path $candidatePath) {
                $filePaths += $candidatePath
                Write-Host "[FOUND] $candidatePath" -ForegroundColor Green
            }
        }
    }
}

# Search in Cursor extensions
Write-Host "[SEARCH] Looking in Cursor extensions..."
$cursorExtensions = Join-Path $env:USERPROFILE ".cursor\extensions"
if (Test-Path $cursorExtensions) {
    $claudeCodeDirs = Get-ChildItem -Path $cursorExtensions -Directory -Filter "anthropic*claude-code*" -ErrorAction SilentlyContinue
    foreach ($dir in $claudeCodeDirs) {
        # Try dist subdirectory first (older versions)
        $candidatePath = Join-Path $dir.FullName "dist\$targetFile"
        if (Test-Path $candidatePath) {
            $filePaths += $candidatePath
            Write-Host "[FOUND] $candidatePath" -ForegroundColor Green
        } else {
            # Try root directory (newer versions)
            $candidatePath = Join-Path $dir.FullName $targetFile
            if (Test-Path $candidatePath) {
                $filePaths += $candidatePath
                Write-Host "[FOUND] $candidatePath" -ForegroundColor Green
            }
        }
    }
}

# If not found anywhere
if ($filePaths.Count -eq 0) {
    Write-Host ""
    Write-Host "[ERROR] '$targetFile' not found in any of the following locations:" -ForegroundColor Red
    Write-Host "  - Current directory"
    Write-Host "  - $env:USERPROFILE\.vscode\extensions\anthropics.claude-code-*\dist\"
    Write-Host "  - $env:USERPROFILE\.vscode\extensions\anthropics.claude-code-*\"
    Write-Host "  - $env:USERPROFILE\.cursor\extensions\anthropic*claude-code*\dist\"
    Write-Host "  - $env:USERPROFILE\.cursor\extensions\anthropic*claude-code*\"
    Write-Host ""
    Write-Host "Please ensure Claude Code extension is installed in VSCode or Cursor."
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""
Write-Host "[INFO] Found $($filePaths.Count) extension(s) to process."
Write-Host ""

if ($undo) {
    Write-Host "This will restore the original files from their .bak backups."
} else {
    Write-Host "A backup of each original file will be created before any changes are made."
}

Write-Host ""
Write-Host "Press any key to continue, or close this window to cancel."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

# Track results
$patchedCount = 0
$skippedCount = 0
$errorCount = 0

# UNDO MODE - Restore backups
if ($undo) {
    foreach ($filePath in $filePaths) {
        Write-Host "=========================================================="
        Write-Host "Processing: $filePath"
        Write-Host "=========================================================="

        $backupPath = "$filePath.bak"

        # Check if backup exists
        if (-not (Test-Path $backupPath)) {
            Write-Host "[SKIP] No backup file found. Nothing to restore." -ForegroundColor Yellow
            $skippedCount++
            Write-Host ""
            continue
        }

        # Restore the backup by moving (renaming) it back
        Write-Host "[ACTION] Restoring from backup..."
        try {
            Move-Item -Path $backupPath -Destination $filePath -Force -ErrorAction Stop
            Write-Host "[SUCCESS] File restored and backup removed!" -ForegroundColor Green

            $patchedCount++
        } catch {
            Write-Host "[ERROR] Failed to restore the file." -ForegroundColor Red
            Write-Host "Error: $_"
            $errorCount++
        }

        Write-Host ""
    }

    # Summary for undo
    Write-Host "=========================================================="
    Write-Host "                   UNDO SUMMARY"
    Write-Host "=========================================================="
    Write-Host "Total extensions found: $($filePaths.Count)"
    Write-Host "Successfully restored:   $patchedCount" -ForegroundColor Green
    Write-Host "Skipped (no backup):    $skippedCount" -ForegroundColor Yellow
    Write-Host "Errors:                 $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
    Write-Host "=========================================================="
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

# PATCH MODE - Apply patches
foreach ($filePath in $filePaths) {
    Write-Host "=========================================================="
    Write-Host "Processing: $filePath"
    Write-Host "=========================================================="

    $backupPath = "$filePath.bak"
    $fileContent = Get-Content -Raw -Path $filePath

    # 2. Try each pattern to find which version this is
    $matchedPattern = $null
    $alreadyPatched = $false

    foreach ($pattern in $patterns) {
        # Check if already patched with this pattern
        if ($fileContent -match [regex]::Escape($pattern.Patched)) {
            Write-Host "[SKIP] File is already patched ($($pattern.Name))." -ForegroundColor Yellow
            $alreadyPatched = $true
            break
        }

        # Check if this pattern matches (original, unpatched version)
        if ($fileContent -match $pattern.Original) {
            $matchedPattern = $pattern
            Write-Host "[DETECT] Detected $($pattern.Name)" -ForegroundColor Cyan
            break
        }
    }

    if ($alreadyPatched) {
        $skippedCount++
        Write-Host ""
        continue
    }

    if (-not $matchedPattern) {
        Write-Host "[WARNING] No matching pattern found for this version." -ForegroundColor Yellow
        Write-Host "The file might be a different version or already modified." -ForegroundColor Yellow
        $skippedCount++
        Write-Host ""
        continue
    }

    # 4. Create backup (if backup file doesn't exist)
    if (-not (Test-Path $backupPath)) {
        Write-Host "[ACTION] Creating backup as '$targetFile.bak'..."
        try {
            Copy-Item -Path $filePath -Destination $backupPath -ErrorAction Stop
            Write-Host "[SUCCESS] Backup created." -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Failed to create backup file. Skipping this file." -ForegroundColor Red
            Write-Host "Error: $_"
            $errorCount++
            Write-Host ""
            continue
        }
    } else {
        Write-Host "[INFO] Backup file already exists. Using existing backup." -ForegroundColor Yellow
    }

    # 5. Execute replacement
    Write-Host "[ACTION] Patching the file..."
    try {
        $newContent = $fileContent -replace $matchedPattern.Original, $matchedPattern.Replacement
        Set-Content -Path $filePath -Value $newContent -NoNewline -ErrorAction Stop

        Write-Host "[SUCCESS] File patched successfully!" -ForegroundColor Green
        $patchedCount++
    } catch {
        Write-Host "[ERROR] Failed to patch the file." -ForegroundColor Red
        Write-Host "Error: $_"
        $errorCount++
    }

    Write-Host ""
}

# Summary
Write-Host "=========================================================="
Write-Host "                   PATCH SUMMARY"
Write-Host "=========================================================="
Write-Host "Total extensions found: $($filePaths.Count)"
Write-Host "Successfully patched:    $patchedCount" -ForegroundColor Green
Write-Host "Skipped (already done): $skippedCount" -ForegroundColor Yellow
Write-Host "Errors:                 $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
Write-Host "=========================================================="
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
