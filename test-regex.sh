#!/bin/bash
cd /home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal

echo "=== ORIGINAL FUNCTION FROM BACKUP ==="
grep -o 'async requestToolPermission([^{]*{[^}]*}[^}]*}' extension.js.bak | head -c 200
echo ""
echo ""

echo "=== TESTING PERL REGEX ==="
echo "Pattern: async requestToolPermission\([^)]*\)\{[^}]*\}\)\)\.result\}"
echo ""

# Create test file
cp extension.js.bak test.js

# Try to apply the patch
perl -i -pe 's/async requestToolPermission\([^)]*\)\{[^}]*\}\)\)\.result\}/REPLACED_FUNCTION/g' test.js

# Check if it replaced
if grep -q 'REPLACED_FUNCTION' test.js; then
    echo "SUCCESS - Pattern matched and replaced!"
else
    echo "FAILED - Pattern did NOT match"
fi

rm -f test.js

echo ""
echo "=== TRYING SIMPLER PATTERN ==="
echo "Pattern: async requestToolPermission\([^)]*\)\{.*?\}\)\)\.result\}"
echo ""

cp extension.js.bak test2.js
perl -i -pe 's/async requestToolPermission\([^)]*\)\{.*?\}\)\)\.result\}/REPLACED_FUNCTION/g' test2.js

if grep -q 'REPLACED_FUNCTION' test2.js; then
    echo "SUCCESS - Simpler pattern matched!"
else
    echo "FAILED - Simpler pattern did NOT match"
fi

rm -f test2.js
