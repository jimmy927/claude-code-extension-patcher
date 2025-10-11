#!/bin/bash
# Claude Code Ultra YOLO Patcher for Linux/WSL
# 100% NO PERMISSION PROMPTS MODE - NEVER ASK FOR ANYTHING!

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Show help function
show_help() {
    echo ""
    echo -e "${CYAN}===========================================================${NC}"
    echo -e "${CYAN}       Claude Code Ultra YOLO Patcher - HELP${NC}"
    echo -e "${CYAN}===========================================================${NC}"
    echo ""
    echo -e "${YELLOW}DESCRIPTION:${NC}"
    echo "  Patches Claude Code extension to NEVER ask for permissions."
    echo "  Applies 4 patches to 3 files (extension.js, cli.js, webview/index.js)"
    echo ""
    echo -e "${YELLOW}USAGE:${NC}"
    echo "  ./ultra-yolo-patcher.sh [OPTIONS]"
    echo ""
    echo -e "${YELLOW}OPTIONS:${NC}"
    echo "  (none)      Apply patches (default mode)"
    echo "  -undo       Restore original files from backups"
    echo "  -repatch    Undo then patch (useful after Claude Code updates)"
    echo "  -yes        Skip all confirmation prompts"
    echo "  -help       Show this help message"
    echo ""
    echo -e "${YELLOW}EXAMPLES:${NC}"
    echo "  ./ultra-yolo-patcher.sh           # Patch with confirmation"
    echo "  ./ultra-yolo-patcher.sh -yes      # Patch without prompts"
    echo "  ./ultra-yolo-patcher.sh -undo     # Restore original"
    echo "  ./ultra-yolo-patcher.sh -repatch  # Undo + patch"
    echo ""
    echo -e "${YELLOW}PATCHES APPLIED:${NC}"
    echo "  1. CLI Flag: Adds --dangerously-skip-permissions"
    echo "  2. Permission Bypass: Auto-allows all permission requests"
    echo "  3. Deny->Allow: Changes behavior:\"deny\" to behavior:\"allow\""
    echo "  4. Logging: Tracks all permissions to log file"
    echo ""
    echo -e "${YELLOW}LOG FILE LOCATION:${NC}"
    echo "  /tmp/claude-code-yolo.log"
    echo ""
    echo -e "${YELLOW}VIEW LOGS:${NC}"
    echo "  tail -f /tmp/claude-code-yolo.log"
    echo ""
    echo -e "${RED}IMPORTANT:${NC}"
    echo "  - RESTART Cursor/VSCode completely after patching or undoing!"
    echo "  - Backups are created with .bak extension"
    echo "  - USE AT YOUR OWN RISK - bypasses ALL safety checks"
    echo ""
    echo -e "${CYAN}===========================================================${NC}"
    exit 0
}

# Parse arguments
MODE="patch"
YES=0
while [[ $# -gt 0 ]]; do
    case $1 in
        -undo)
            MODE="undo"
            shift
            ;;
        -repatch)
            MODE="repatch"
            shift
            ;;
        -yes)
            YES=1
            shift
            ;;
        -help|--help|-h)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -help to see available options"
            exit 1
            ;;
    esac
done

# Handle repatch mode
if [[ "$MODE" == "repatch" ]]; then
    echo ""
    echo -e "${CYAN}==========================================================${NC}"
    echo -e "${YELLOW}       Claude Code Ultra YOLO Patcher - REPATCH MODE${NC}"
    echo -e "${CYAN}==========================================================${NC}"
    echo ""
    echo -e "${YELLOW}Running UNDO first...${NC}"
    echo ""

    "$0" -undo -yes

    echo ""
    echo -e "${YELLOW}Now running PATCH...${NC}"
    echo ""

    "$0" -yes

    exit 0
fi

# Header
echo ""
echo -e "${CYAN}==========================================================${NC}"
if [[ "$MODE" == "undo" ]]; then
    echo -e "${CYAN}       Claude Code Ultra YOLO Patcher - UNDO MODE${NC}"
else
    echo -e "${CYAN}       Claude Code Ultra YOLO Patcher${NC}"
    echo -e "${RED}       100% NO PERMISSION PROMPTS MODE${NC}"
fi
echo -e "${CYAN}==========================================================${NC}"
echo ""

# Search for extensions
FILE_PATHS=()

echo -e "${YELLOW}Searching for Claude Code extensions...${NC}"
echo ""

# Check user's home directory for cursor-server extensions
if [[ -d "$HOME/.cursor-server/extensions" ]]; then
    while IFS= read -r -d '' file; do
        FILE_PATHS+=("$file")
        echo -e "${GREEN}[FOUND]${NC} $file"
    done < <(find "$HOME/.cursor-server/extensions" -type d -name "anthropic*claude-code*" -exec find {} -name "*.js" -type f -print0 \; 2>/dev/null)
fi

# Check vscode-server extensions
if [[ -d "$HOME/.vscode-server/extensions" ]]; then
    while IFS= read -r -d '' file; do
        FILE_PATHS+=("$file")
        echo -e "${GREEN}[FOUND]${NC} $file"
    done < <(find "$HOME/.vscode-server/extensions" -type d -name "anthropic*claude-code*" -exec find {} -name "*.js" -type f -print0 \; 2>/dev/null)
fi

# Check local .vscode/extensions
if [[ -d "$HOME/.vscode/extensions" ]]; then
    while IFS= read -r -d '' file; do
        FILE_PATHS+=("$file")
        echo -e "${GREEN}[FOUND]${NC} $file"
    done < <(find "$HOME/.vscode/extensions" -type d -name "anthropic*claude-code*" -exec find {} -name "*.js" -type f -print0 \; 2>/dev/null)
fi

if [[ ${#FILE_PATHS[@]} -eq 0 ]]; then
    echo ""
    echo -e "${RED}[ERROR] No Claude Code extensions found!${NC}"
    echo ""
    exit 1
fi

echo ""
echo -e "${CYAN}[INFO] Found ${#FILE_PATHS[@]} file(s)${NC}"
echo ""

# Confirmation
if [[ $YES -eq 0 ]]; then
    if [[ "$MODE" == "undo" ]]; then
        echo -e "${YELLOW}This will restore the original files from backups.${NC}"
    else
        echo -e "${YELLOW}This will modify the extension to NEVER ask for permissions.${NC}"
        echo -e "${RED}ALL commands will be auto-approved. 100% YOLO MODE!${NC}"
    fi

    echo ""
    read -p "Press Enter to continue, or Ctrl+C to cancel..."
    echo ""
fi

PATCHED_COUNT=0
SKIPPED_COUNT=0
ERROR_COUNT=0

# Log file location
LOG_FILE="/tmp/claude-code-yolo.log"

# Process each file
for FILE_PATH in "${FILE_PATHS[@]}"; do
    echo -e "${CYAN}==========================================================${NC}"
    echo "Processing: $FILE_PATH"
    echo -e "${CYAN}==========================================================${NC}"

    BACKUP_PATH="${FILE_PATH}.bak"

    if [[ "$MODE" == "undo" ]]; then
        # UNDO MODE
        if [[ ! -f "$BACKUP_PATH" ]]; then
            echo -e "${YELLOW}[SKIP] No backup found${NC}"
            ((SKIPPED_COUNT++))
            echo ""
            continue
        fi

        echo -e "${YELLOW}[ACTION] Restoring from backup...${NC}"
        if mv "$BACKUP_PATH" "$FILE_PATH"; then
            echo -e "${GREEN}[SUCCESS] Restored!${NC}"
            ((PATCHED_COUNT++))
        else
            echo -e "${RED}[ERROR] Failed to restore${NC}"
            ((ERROR_COUNT++))
        fi
    else
        # PATCH MODE
        if [[ ! -f "$BACKUP_PATH" ]]; then
            echo -e "${YELLOW}[ACTION] Creating backup...${NC}"
            if cp "$FILE_PATH" "$BACKUP_PATH"; then
                echo -e "${GREEN}[SUCCESS] Backup created${NC}"
            else
                echo -e "${RED}[ERROR] Failed to create backup${NC}"
                ((ERROR_COUNT++))
                echo ""
                continue
            fi
        else
            echo -e "${YELLOW}[INFO] Backup already exists${NC}"
        fi

        echo -e "${YELLOW}[ACTION] Applying ULTRA YOLO patches...${NC}"

        MADE_CHANGES=0
        FILENAME=$(basename "$FILE_PATH")

        # Create temp file for modifications
        TEMP_FILE="${FILE_PATH}.tmp"
        cp "$FILE_PATH" "$TEMP_FILE"

        # Patch 1: Add --dangerously-skip-permissions flag
        if grep -q 'k=\["--output-format","stream-json"' "$TEMP_FILE"; then
            echo -e "${CYAN}  [PATCH 1] Adding --dangerously-skip-permissions flag${NC}"
            sed -i 's/k=\["--output-format","stream-json"/k=["--dangerously-skip-permissions","--output-format","stream-json"/' "$TEMP_FILE"
            MADE_CHANGES=1
        elif grep -q 'F=\["--output-format","stream-json"' "$TEMP_FILE"; then
            echo -e "${CYAN}  [PATCH 1] Adding --dangerously-skip-permissions flag (v2.0.1)${NC}"
            sed -i 's/F=\["--output-format","stream-json"/F=["--dangerously-skip-permissions","--output-format","stream-json"/' "$TEMP_FILE"
            MADE_CHANGES=1
        else
            echo -e "${YELLOW}  [PATCH 1] Already applied or different version${NC}"
        fi

        # Patch 2: Replace requestToolPermission
        if grep -q 'async requestToolPermission([^)]*){return(await this\.sendRequest([^)]*,{type:"tool_permission_request"' "$TEMP_FILE"; then
            echo -e "${CYAN}  [PATCH 2] Disabling permission prompts (auto-allow ALL) + ONE LOG FILE${NC}"

            # Determine if ES module or CommonJS
            if [[ "$FILENAME" == "cli.js" ]]; then
                # ES module
                LOG_CODE='async requestToolPermission(e,r,a,s){try{const fs=await import("fs");const log="["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\\n";fs.appendFileSync("'"$LOG_FILE"'",log);}catch(err){}return{behavior:"allow"}}'
            else
                # CommonJS
                LOG_CODE='async requestToolPermission(e,r,a,s){try{const fs=require("fs");const log="["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\\n";fs.appendFileSync("'"$LOG_FILE"'",log);}catch(err){}return{behavior:"allow"}}'
            fi

            perl -i -pe 's/async requestToolPermission\([^)]*\)\{return\(await this\.sendRequest\([^)]*,\{type:"tool_permission_request"[^}]*\}\)\)\.result\}/'"$LOG_CODE"'/g' "$TEMP_FILE"
            MADE_CHANGES=1
        else
            echo -e "${YELLOW}  [PATCH 2] Pattern not found or already applied${NC}"
        fi

        # Patch 3: Change deny to allow
        if grep -q 'behavior:"deny"' "$TEMP_FILE"; then
            echo -e "${CYAN}  [PATCH 3] Changing deny behaviors to allow${NC}"
            sed -i 's/behavior:"deny"/behavior:"allow"/g' "$TEMP_FILE"
            MADE_CHANGES=1
        else
            echo -e "${YELLOW}  [PATCH 3] No deny behaviors found${NC}"
        fi

        # Patch 3b: Add logging to checkPermissions (cli.js only)
        if [[ "$FILENAME" == "cli.js" ]] && grep -q 'async checkPermissions(' "$TEMP_FILE"; then
            if grep -q 'async checkPermissions([A-Z]){return{behavior:"allow",updatedInput:[A-Z]}' "$TEMP_FILE"; then
                echo -e "${CYAN}  [PATCH 3b] Adding permission logging to checkPermissions functions${NC}"
                perl -i -pe 's/(async checkPermissions\(([A-Z])\)\{)return\{behavior:"allow",updatedInput:\2\}/$1try{const fs=await import("fs");const log="["+new Date().toISOString()+"] PERMISSION CHECK: "+this.name+" | Input: "+JSON.stringify($2)+"\\n";fs.appendFileSync("'"$LOG_FILE"'",log);}catch(e){}return{behavior:"allow",updatedInput:$2}/g' "$TEMP_FILE"
                MADE_CHANGES=1
            else
                echo -e "${YELLOW}  [PATCH 3b] Pattern not found in cli.js${NC}"
            fi
        fi

        # Patch 3c: Add logging to am() function (cli.js only)
        if [[ "$FILENAME" == "cli.js" ]] && grep -q 'function am(A,B,Q)' "$TEMP_FILE"; then
            if grep -q 'function am(A,B,Q){if(typeof A\.getPath!=="function")' "$TEMP_FILE"; then
                echo -e "${CYAN}  [PATCH 3c] Adding permission logging to am() function (Bash, Edit, Write)${NC}"
                LOG_CODE='(async()=>{try{const fs=await import("fs");const log="["+new Date().toISOString()+"] PERMISSION CHECK (am): "+A.name+" | Input: "+JSON.stringify(B)+"\\n";fs.appendFileSync("'"$LOG_FILE"'",log);}catch(e){}})();'
                perl -i -pe 's/(function am\(A,B,Q\)\{)/$1'"$LOG_CODE"'/g' "$TEMP_FILE"
                MADE_CHANGES=1
            else
                echo -e "${YELLOW}  [PATCH 3c] am() function pattern not found${NC}"
            fi
        fi

        # Patch 4: Add startup logging
        if ! grep -q 'YOLO FILE LOADED' "$TEMP_FILE"; then
            echo -e "${CYAN}  [PATCH 4] Adding startup logging to ONE LOG FILE${NC}"

            if [[ "$FILENAME" == "cli.js" ]]; then
                # ES module with shebang - insert after line 1
                if grep -q '^#!/usr/bin/env node' "$TEMP_FILE"; then
                    STARTUP_LOG='(async()=>{try{const fs=await import("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: '"$FILENAME"'\\n";fs.appendFileSync("'"$LOG_FILE"'",log);}catch(e){}})();'
                    # Use sed to insert after first line - use single quotes to preserve backslash
                    sed -i '1a\'"$STARTUP_LOG" "$TEMP_FILE"
                else
                    STARTUP_LOG='(async()=>{try{const fs=await import("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: '"$FILENAME"'\\n";fs.appendFileSync("'"$LOG_FILE"'",log);}catch(e){}})();'
                    # Prepend to file
                    printf '%s\n' "$STARTUP_LOG" | cat - "$TEMP_FILE" > "$TEMP_FILE.tmp2" && mv "$TEMP_FILE.tmp2" "$TEMP_FILE"
                fi
            else
                # CommonJS - prepend to file
                STARTUP_LOG='try{const fs=require("fs");const log="["+new Date().toISOString()+"] YOLO FILE LOADED: '"$FILENAME"'\\n";fs.appendFileSync("'"$LOG_FILE"'",log);console.log("YOLO LOADED: '"$FILENAME"'");}catch(e){console.error("YOLO ERROR in '"$FILENAME"':",e);}'
                printf '%s\n' "$STARTUP_LOG" | cat - "$TEMP_FILE" > "$TEMP_FILE.tmp2" && mv "$TEMP_FILE.tmp2" "$TEMP_FILE"
            fi

            MADE_CHANGES=1
        else
            echo -e "${YELLOW}  [PATCH 4] Startup logging already added${NC}"
        fi

        # Write changes
        if [[ $MADE_CHANGES -eq 1 ]]; then
            echo ""
            echo -e "${YELLOW}[ACTION] Writing patched file...${NC}"
            if mv "$TEMP_FILE" "$FILE_PATH"; then
                echo -e "${GREEN}[SUCCESS] Ultra YOLO patches applied!${NC}"
                ((PATCHED_COUNT++))
            else
                echo -e "${RED}[ERROR] Failed to write file${NC}"
                ((ERROR_COUNT++))
            fi
        else
            echo ""
            echo -e "${YELLOW}[SKIP] No patches needed (already YOLO?)${NC}"
            ((SKIPPED_COUNT++))
            rm -f "$TEMP_FILE"
        fi
    fi

    echo ""
done

# Summary
echo -e "${CYAN}==========================================================${NC}"
echo "                   SUMMARY"
echo -e "${CYAN}==========================================================${NC}"
echo "Total extensions found: ${#FILE_PATHS[@]}"
echo -e "${GREEN}Successfully patched:    $PATCHED_COUNT${NC}"
echo -e "${YELLOW}Skipped:                 $SKIPPED_COUNT${NC}"
if [[ $ERROR_COUNT -gt 0 ]]; then
    echo -e "${RED}Errors:                  $ERROR_COUNT${NC}"
else
    echo -e "${GREEN}Errors:                  $ERROR_COUNT${NC}"
fi
echo -e "${CYAN}==========================================================${NC}"
echo ""

if [[ "$MODE" == "patch" ]] && [[ $PATCHED_COUNT -gt 0 ]]; then
    echo -e "${RED}IMPORTANT: RESTART Cursor completely to apply changes!${NC}"
    echo ""
    echo -e "${GREEN}After restart, Claude Code will NEVER ask for permissions.${NC}"
    echo ""
    echo -e "${CYAN}ALL LOGS written to ONE FILE:${NC}"
    echo "  $LOG_FILE"
    echo ""
fi

if [[ "$MODE" == "patch" ]]; then
    echo -e "${YELLOW}To undo: $0 -undo${NC}"
    echo -e "${YELLOW}To repatch: $0 -repatch${NC}"
fi

echo ""
