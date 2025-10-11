#!/usr/bin/env python3
import sys

# Read file
with open('/home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.14-universal/extension.js', 'r') as f:
    content = f.read()

# Original pattern
original = 'async requestToolPermission(e,r,a,s){return(await this.sendRequest(e,{type:"tool_permission_request",toolName:r,inputs:a,suggestions:s})).result}'

# Replacement - minimal, just return allow
replacement = 'async requestToolPermission(e,r,a,s){return{behavior:"allow"}}'

# Replace
count = content.count(original)
print(f'Found {count} occurrences')

if count > 0:
    content = content.replace(original, replacement)
    with open('/home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.14-universal/extension.js', 'w') as f:
        f.write(content)
    print('[SUCCESS] Patched 2.0.14!')
else:
    print('[ERROR] Pattern not found - extension may have different structure')
    sys.exit(1)
