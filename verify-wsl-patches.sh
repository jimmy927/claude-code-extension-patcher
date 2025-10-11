#!/bin/bash
# Verify all WSL patches

EXT_DIR="/home/jimmy/.cursor-server/extensions/anthropic.claude-code-2.0.10-universal"

cd "$EXT_DIR" || exit 1

echo "=========================================="
echo "EXTENSION.JS VERIFICATION"
echo "=========================================="
echo ""
echo "File sizes:"
echo "  Patched: $(stat -c%s extension.js 2>/dev/null || echo 'NOT FOUND')"
echo "  Backup:  $(stat -c%s extension.js.bak 2>/dev/null || echo 'NOT FOUND')"
echo ""

echo "Patch 4 - Startup logging:"
echo "  YOLO marker: $(grep -c 'YOLO FILE LOADED' extension.js 2>/dev/null || echo 0)"
echo ""

echo "Patch 1 - CLI flag:"
echo "  Has 'output-format' in backup: $(grep -c 'output-format' extension.js.bak 2>/dev/null || echo 0)"
echo "  Has 'dangerously-skip-permissions' in patched: $(grep -c 'dangerously-skip-permissions' extension.js 2>/dev/null || echo 0)"
echo ""

echo "Patch 2 - requestToolPermission:"
echo "  Pattern in backup (first 80 chars):"
grep -o 'async requestToolPermission([^)]*){return(await this\.sendRequest' extension.js.bak 2>/dev/null | head -c 80 || echo "  NOT FOUND"
echo ""
echo "  Has AUTO-ALLOWED in patched: $(grep -c 'AUTO-ALLOWED' extension.js 2>/dev/null || echo 0)"
echo ""

echo "Patch 3 - behavior:deny:"
echo "  Count in backup: $(grep -c 'behavior:"deny"' extension.js.bak 2>/dev/null || echo 0)"
echo "  Count in patched: $(grep -c 'behavior:"deny"' extension.js 2>/dev/null || echo 0)"
echo ""

echo "=========================================="
echo "CLI.JS VERIFICATION"
echo "=========================================="
echo ""
echo "File sizes:"
echo "  Patched: $(stat -c%s resources/claude-code/cli.js 2>/dev/null || echo 'NOT FOUND')"
echo "  Backup:  $(stat -c%s resources/claude-code/cli.js.bak 2>/dev/null || echo 'NOT FOUND')"
echo ""

echo "Patch 4 - Startup logging:"
echo "  YOLO marker: $(grep -c 'YOLO FILE LOADED' resources/claude-code/cli.js 2>/dev/null || echo 0)"
echo "  First 2 lines:"
head -2 resources/claude-code/cli.js 2>/dev/null | od -c | head -10
echo ""

echo "Patch 1 - CLI flag:"
echo "  Has 'dangerously-skip-permissions': $(grep -c 'dangerously-skip-permissions' resources/claude-code/cli.js 2>/dev/null || echo 0)"
echo ""

echo "Patch 3b - checkPermissions:"
echo "  Pattern 'async checkPermissions' in backup: $(grep -c 'async checkPermissions' resources/claude-code/cli.js.bak 2>/dev/null || echo 0)"
echo "  Has 'PERMISSION CHECK' in patched: $(grep -c 'PERMISSION CHECK' resources/claude-code/cli.js 2>/dev/null || echo 0)"
echo ""

echo "Patch 3c - am() function:"
echo "  Pattern 'function am' in backup: $(grep -c 'function am' resources/claude-code/cli.js.bak 2>/dev/null || echo 0)"
echo ""

echo "Patch 3 - behavior:deny:"
echo "  Count in backup: $(grep -c 'behavior:"deny"' resources/claude-code/cli.js.bak 2>/dev/null || echo 0)"
echo "  Count in patched: $(grep -c 'behavior:"deny"' resources/claude-code/cli.js 2>/dev/null || echo 0)"
echo ""

echo "=========================================="
echo "WEBVIEW/INDEX.JS VERIFICATION"
echo "=========================================="
echo ""
echo "File sizes:"
echo "  Patched: $(stat -c%s webview/index.js 2>/dev/null || echo 'NOT FOUND')"
echo "  Backup:  $(stat -c%s webview/index.js.bak 2>/dev/null || echo 'NOT FOUND')"
echo ""

echo "Patch 4 - Startup logging:"
echo "  YOLO marker: $(grep -c 'YOLO FILE LOADED' webview/index.js 2>/dev/null || echo 0)"
echo ""

echo "Patch 3 - behavior:deny:"
echo "  Count in backup: $(grep -c 'behavior:"deny"' webview/index.js.bak 2>/dev/null || echo 0)"
echo "  Count in patched: $(grep -c 'behavior:"deny"' webview/index.js 2>/dev/null || echo 0)"
echo ""

echo "=========================================="
echo "SUMMARY"
echo "=========================================="
echo ""
echo "Log file location: /tmp/claude-code-yolo.log"
echo "Last 5 entries:"
tail -5 /tmp/claude-code-yolo.log 2>/dev/null || echo "Log file not found or empty"
