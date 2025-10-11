#!/bin/bash

EXT_FILE="/home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal/extension.js"
BACKUP_FILE="${EXT_FILE}.bak"
LOG_FILE="/tmp/claude-code-yolo.log"

echo "=== MANUAL PATCH TEST ==="
echo ""

# Restore from backup first
echo "1. Restoring from backup..."
cp "$BACKUP_FILE" "$EXT_FILE"

echo "2. Before patch:"
grep -o 'async requestToolPermission([^{]*{[^}]*}' "$EXT_FILE" | head -c 150
echo ""
echo ""

# Apply the patch
echo "3. Applying perl patch..."
LOG_CODE='async requestToolPermission(e,r,a,s){try{const fs=require("fs");const log="["+new Date().toISOString()+"] PERMISSION REQUEST - Tool: "+r+" | Inputs: "+JSON.stringify(a)+" | AUTO-ALLOWED\n";fs.appendFileSync("'"$LOG_FILE"'",log);}catch(err){}return{behavior:"allow"}}'

perl -i -pe 's/async requestToolPermission\([^)]*\)\{[^}]*\}\)\)\.result\}/'"$LOG_CODE"'/g' "$EXT_FILE"

echo "4. After patch:"
grep -o 'async requestToolPermission([^{]*{[^}]*}' "$EXT_FILE" | head -c 150
echo ""
echo ""

echo "5. Does it have AUTO-ALLOWED?"
if grep -q 'AUTO-ALLOWED' "$EXT_FILE"; then
    echo "YES - Patch applied successfully!"
else
    echo "NO - Patch did NOT apply"
fi

echo ""
echo "6. Does it still have sendRequest?"
if grep -q 'requestToolPermission.*sendRequest' "$EXT_FILE"; then
    echo "YES - Still has sendRequest (PROBLEM!)"
else
    echo "NO - sendRequest removed (SUCCESS!)"
fi
