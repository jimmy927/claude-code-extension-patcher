#!/bin/bash
cd /home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal

echo "=== Looking for requestToolPermission pattern ==="
echo ""
echo "Full pattern from backup (first 300 chars):"
grep -o 'async requestToolPermission([^{]*{[^}]*}[^}]*}' extension.js.bak | head -c 300
echo ""
echo ""

echo "=== Current bash script pattern ==="
echo 'async requestToolPermission([^)]*){return(await this\.sendRequest([^)]*,{type:"tool_permission_request"'
echo ""

echo "=== Does it match? ==="
if grep -q 'async requestToolPermission([^)]*){return(await this\.sendRequest([^)]*,{type:"tool_permission_request"' extension.js.bak; then
    echo "YES - Pattern matches"
else
    echo "NO - Pattern does NOT match"
fi
