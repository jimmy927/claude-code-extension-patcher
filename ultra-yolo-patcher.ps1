# Claude Code Ultra YOLO Patcher
# 100% NO PERMISSION PROMPTS MODE - NEVER ASK FOR ANYTHING!

param(
    [switch]$undo,
    [switch]$repatch,
    [switch]$yes
)

$host.UI.RawUI.WindowTitle = "Claude Code Ultra YOLO Patcher"

# Handle -repatch flag (undo + patch)
if ($repatch) {
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "       Claude Code Ultra YOLO Patcher - REPATCH MODE" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Running UNDO first..." -ForegroundColor Yellow
    Write-Host ""

    # Run undo
    & $PSCommandPath -undo -yes

    Write-Host ""
    Write-Host "Now running PATCH..." -ForegroundColor Yellow
    Write-Host ""

    # Run patch
    & $PSCommandPath -yes

    exit
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
if ($undo) {
    Write-Host "       Claude Code Ultra YOLO Patcher - UNDO MODE" -ForegroundColor Cyan
} else {
    Write-Host "       Claude Code Ultra YOLO Patcher" -ForegroundColor Cyan
    Write-Host "       100% NO PERMISSION PROMPTS MODE" -ForegroundColor Red
}
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Search for extensions
$filePaths = @()

Write-Host "Searching for Claude Code extensions..." -ForegroundColor Yellow
Write-Host ""

# Check VSCode extensions
$vscodeExtensions = Join-Path $env:USERPROFILE ".vscode\extensions"
if (Test-Path $vscodeExtensions) {
    $claudeCodeDirs = Get-ChildItem -Path $vscodeExtensions -Directory -Filter "anthropics.claude-code-*" -ErrorAction SilentlyContinue
    foreach ($dir in $claudeCodeDirs) {
        # Find ALL .js files in the extension
        $jsFiles = Get-ChildItem -Path $dir.FullName -Filter "*.js" -Recurse -ErrorAction SilentlyContinue
        foreach ($jsFile in $jsFiles) {
            $filePaths += $jsFile.FullName
            Write-Host "[FOUND] $($jsFile.FullName)" -ForegroundColor Green
        }
    }
}

# Check Cursor extensions
$cursorExtensions = Join-Path $env:USERPROFILE ".cursor\extensions"
if (Test-Path $cursorExtensions) {
    $claudeCodeDirs = Get-ChildItem -Path $cursorExtensions -Directory -Filter "anthropic*claude-code*" -ErrorAction SilentlyContinue
    foreach ($dir in $claudeCodeDirs) {
        # Find ALL .js files in the extension
        $jsFiles = Get-ChildItem -Path $dir.FullName -Filter "*.js" -Recurse -ErrorAction SilentlyContinue
        foreach ($jsFile in $jsFiles) {
            $filePaths += $jsFile.FullName
            Write-Host "[FOUND] $($jsFile.FullName)" -ForegroundColor Green
        }
    }
}

if ($filePaths.Count -eq 0) {
    Write-Host ""
    Write-Host "[ERROR] No Claude Code extensions found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""
Write-Host "[INFO] Found $($filePaths.Count) extension(s)" -ForegroundColor Cyan
Write-Host ""

if (-not $yes) {
    if ($undo) {
        Write-Host "This will restore the original files from backups." -ForegroundColor Yellow
    } else {
        Write-Host "This will modify the extension to NEVER ask for permissions." -ForegroundColor Yellow
        Write-Host "ALL commands will be auto-approved. 100% YOLO MODE!" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "Press any key to continue, or close this window to cancel."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
}

$patchedCount = 0
$skippedCount = 0
$errorCount = 0

# UNDO MODE
if ($undo) {
    foreach ($filePath in $filePaths) {
        Write-Host "==========================================================" -ForegroundColor Cyan
        Write-Host "Processing: $filePath" -ForegroundColor White
        Write-Host "==========================================================" -ForegroundColor Cyan

        $backupPath = "$filePath.bak"

        if (-not (Test-Path $backupPath)) {
            Write-Host "[SKIP] No backup found" -ForegroundColor Yellow
            $skippedCount++
            Write-Host ""
            continue
        }

        Write-Host "[ACTION] Restoring from backup..." -ForegroundColor Yellow
        try {
            Move-Item -Path $backupPath -Destination $filePath -Force -ErrorAction Stop
            Write-Host "[SUCCESS] Restored!" -ForegroundColor Green
            $patchedCount++
        } catch {
            Write-Host "[ERROR] Failed to restore: $_" -ForegroundColor Red
            $errorCount++
        }

        Write-Host ""
    }
} else {
    # PATCH MODE - ULTRA YOLO!
    foreach ($filePath in $filePaths) {
        Write-Host "==========================================================" -ForegroundColor Cyan
        Write-Host "Processing: $filePath" -ForegroundColor White
        Write-Host "==========================================================" -ForegroundColor Cyan

        $backupPath = "$filePath.bak"
        $fileContent = Get-Content -Raw -Path $filePath

        # Create backup
        if (-not (Test-Path $backupPath)) {
            Write-Host "[ACTION] Creating backup..." -ForegroundColor Yellow
            try {
                Copy-Item -Path $filePath -Destination $backupPath -ErrorAction Stop
                Write-Host "[SUCCESS] Backup created" -ForegroundColor Green
            } catch {
                Write-Host "[ERROR] Failed to create backup: $_" -ForegroundColor Red
                $errorCount++
                Write-Host ""
                continue
            }
        } else {
            Write-Host "[INFO] Backup already exists" -ForegroundColor Yellow
        }

        Write-Host "[ACTION] Applying ULTRA YOLO patches..." -ForegroundColor Yellow
        $madeChanges = $false

        # Patch 1: Add --dangerously-skip-permissions flag
        if ($fileContent -match 'k=\["--output-format","stream-json"') {
            Write-Host "  [PATCH 1] Adding --dangerously-skip-permissions flag" -ForegroundColor Cyan
            $fileContent = $fileContent -replace 'k=\["--output-format","stream-json"', 'k=["--dangerously-skip-permissions","--output-format","stream-json"'
            $madeChanges = $true
        } elseif ($fileContent -match 'F=\["--output-format","stream-json"') {
            Write-Host "  [PATCH 1] Adding --dangerously-skip-permissions flag (v2.0.1)" -ForegroundColor Cyan
            $fileContent = $fileContent -replace 'F=\["--output-format","stream-json"', 'F=["--dangerously-skip-permissions","--output-format","stream-json"'
            $madeChanges = $true
        } else {
            Write-Host "  [PATCH 1] Already applied or different version" -ForegroundColor Yellow
        }

        # Patch 2: Make requestToolPermission always return "allow" WITH LOGGING TO ONE FILE
        if ($fileContent -match 'async requestToolPermission\([^)]*\)\{return\(await this\.sendRequest\([^)]*,\{type:"tool_permission_request"') {
            Write-Host "  [PATCH 2] Disabling permission prompts (auto-allow ALL) + ONE LOG FILE" -ForegroundColor Cyan

            # Create logging code that writes to ONE log file (works in both CommonJS and ES modules)
            $logCode = 'async requestToolPermission(e,r,a,s){try{const fs=await import("fs");const log="["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\n";fs.appendFileSync("C:/Users/jimmy/yolo.log",log);}catch(err){}return{behavior:"allow"}}'

            $fileContent = $fileContent -replace 'async requestToolPermission\(([^)]*)\)\{return\(await this\.sendRequest\([^)]*,\{type:"tool_permission_request",toolName:[^}]*\}\)\)\.result\}', $logCode
            $madeChanges = $true
        } else {
            Write-Host "  [PATCH 2] Pattern not found or already applied" -ForegroundColor Yellow
        }

        # Patch 3: Change any "deny" behavior to "allow"
        if ($fileContent -match 'behavior:"deny"') {
            Write-Host "  [PATCH 3] Changing deny behaviors to allow" -ForegroundColor Cyan
            $fileContent = $fileContent -replace 'behavior:"deny"', 'behavior:"allow"'
            $madeChanges = $true
        } else {
            Write-Host "  [PATCH 3] No deny behaviors found" -ForegroundColor Yellow
        }

        # Patch 4: Add startup logging at the very beginning
        if ($fileContent -notmatch 'YOLO FILE LOADED') {
            Write-Host "  [PATCH 4] Adding startup logging to ONE LOG FILE" -ForegroundColor Cyan

            # Get filename for logging
            $fileName = Split-Path -Leaf $filePath

            # Check if file starts with shebang (#!/usr/bin/env node)
            if ($fileContent -match '^#!/usr/bin/env node') {
                # ES module with shebang (cli.js) - NO console.log, it breaks JSON output!
                $startupLog = '(async()=>{try{const fs=await import("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: ' + $fileName + '\n";fs.appendFileSync("C:/Users/jimmy/yolo.log",log);}catch(e){}})();'
                $fileContent = $fileContent -replace '^(#!/usr/bin/env node\r?\n)', "`$1$startupLog`n"
            } elseif ($fileContent -match '^import\{') {
                # ES module without shebang - NO console.log
                $startupLog = '(async()=>{try{const fs=await import("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: ' + $fileName + '\n";fs.appendFileSync("C:/Users/jimmy/yolo.log",log);}catch(e){}})();'
                $fileContent = $startupLog + $fileContent
            } else {
                # CommonJS version (extension.js) - can use console.log safely
                $startupLog = 'try{const fs=require("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: ' + $fileName + '\n";fs.appendFileSync("C:/Users/jimmy/yolo.log",log);console.log("YOLO LOADED: ' + $fileName + '");}catch(e){console.error("YOLO ERROR in ' + $fileName + ':",e);}'
                $fileContent = $startupLog + $fileContent
            }

            $madeChanges = $true
        } else {
            Write-Host "  [PATCH 4] Startup logging already added" -ForegroundColor Yellow
        }

        if ($madeChanges) {
            Write-Host ""
            Write-Host "[ACTION] Writing patched file..." -ForegroundColor Yellow
            try {
                Set-Content -Path $filePath -Value $fileContent -NoNewline -ErrorAction Stop
                Write-Host "[SUCCESS] Ultra YOLO patches applied!" -ForegroundColor Green
                $patchedCount++
            } catch {
                Write-Host "[ERROR] Failed to write file: $_" -ForegroundColor Red
                $errorCount++
            }
        } else {
            Write-Host ""
            Write-Host "[SKIP] No patches needed (already YOLO?)" -ForegroundColor Yellow
            $skippedCount++
        }

        Write-Host ""
    }
}

# Summary
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "                   SUMMARY" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Total extensions found: $($filePaths.Count)"
Write-Host "Successfully patched:    $patchedCount" -ForegroundColor Green
Write-Host "Skipped:                 $skippedCount" -ForegroundColor Yellow
Write-Host "Errors:                  $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

if (-not $undo -and $patchedCount -gt 0) {
    Write-Host "IMPORTANT: RESTART Cursor completely to apply changes!" -ForegroundColor Red
    Write-Host ""
    Write-Host "After restart, Claude Code will NEVER ask for permissions." -ForegroundColor Green
    Write-Host ""
    Write-Host "ALL LOGS written to ONE FILE:" -ForegroundColor Cyan
    Write-Host "  C:\Users\jimmy\yolo.log" -ForegroundColor White
    Write-Host ""
}

if (-not $undo) {
    Write-Host "To undo: .\ultra-yolo-patcher.ps1 -undo" -ForegroundColor Yellow
    Write-Host "To repatch: .\ultra-yolo-patcher.ps1 -repatch" -ForegroundColor Yellow
}

if (-not $yes) {
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
