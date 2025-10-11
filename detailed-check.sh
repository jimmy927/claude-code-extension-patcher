#!/bin/bash
cd /home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal

echo "==========================================="
echo "DETAILED EXTENSION.JS CHECK"
echo "==========================================="
echo ""

echo "1. File sizes:"
echo "   Patched: $(stat -c%s extension.js)"
echo "   Backup:  $(stat -c%s extension.js.bak)"
echo ""

echo "2. requestToolPermission function in CURRENT file:"
grep -o 'async requestToolPermission([^}]*}' extension.js | head -c 300
echo ""
echo ""

echo "3. Does current file return behavior:allow?"
if grep -q 'async requestToolPermission.*return{behavior:"allow"}' extension.js; then
    echo "   YES - Has immediate return with allow"
else
    echo "   NO - Does NOT have immediate allow return"
fi
echo ""

echo "4. Does current file still call sendRequest?"
if grep -q 'requestToolPermission.*sendRequest' extension.js; then
    echo "   YES - Still calls sendRequest (NOT PATCHED!)"
else
    echo "   NO - Does not call sendRequest (PATCHED!)"
fi
echo ""

echo "5. Extract full requestToolPermission from current:"
perl -ne 'print if /async requestToolPermission\([^{]*\{[^}]*\}/' extension.js | head -c 500
echo ""
echo ""

echo "==========================================="
echo "CHECKING WINDOWS EXTENSION"
echo "==========================================="
echo ""

WIN_EXT="/mnt/c/Users/jimmy/.cursor/extensions/anthropic.claude-code-2.0.10-universal/extension.js"

if [ -f "$WIN_EXT" ]; then
    echo "1. Windows extension.js size: $(stat -c%s $WIN_EXT)"
    echo ""

    echo "2. requestToolPermission in Windows file:"
    grep -o 'async requestToolPermission([^}]*}' "$WIN_EXT" | head -c 300
    echo ""
    echo ""

    echo "3. Does Windows file return behavior:allow?"
    if grep -q 'async requestToolPermission.*return{behavior:"allow"}' "$WIN_EXT"; then
        echo "   YES - Has immediate return with allow"
    else
        echo "   NO - Does NOT have immediate allow return"
    fi
    echo ""

    echo "4. Does Windows file still call sendRequest?"
    if grep -q 'requestToolPermission.*sendRequest' "$WIN_EXT"; then
        echo "   YES - Still calls sendRequest (NOT PATCHED!)"
    else
        echo "   NO - Does not call sendRequest (PATCHED!)"
    fi
else
    echo "Windows extension NOT FOUND at $WIN_EXT"
fi
