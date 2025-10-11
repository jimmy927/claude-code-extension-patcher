#!/bin/bash
cd /home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal

echo "=== Checking CURRENT extension.js ==="
echo ""
echo "requestToolPermission function (first 250 chars):"
grep -o 'async requestToolPermission[^}]*}' extension.js | head -c 250
echo ""
echo ""

echo "Does it still have the original pattern?"
if grep -q 'return(await this\.sendRequest' extension.js; then
    echo "YES - File still has original pattern, patch should work"
else
    echo "NO - File was modified, pattern changed"
fi
echo ""

echo "Checking if already has allow behavior:"
if grep -q 'requestToolPermission.*behavior:"allow"' extension.js; then
    echo "YES - Already patched with allow behavior"
else
    echo "NO - Does not have allow behavior yet"
fi
