#!/usr/bin/env pwsh

Write-Host "TEST: ultra-yolo-patcher.py via TEMP FILE (no stdin)"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "ultra-yolo-patcher.py"
$EscapedPath = $PythonScript -replace '\\', '\\'
$WslScriptPath = (wsl wslpath -u `"$EscapedPath`" 2>&1 | Select-Object -First 1).Trim()

Write-Host "Creating temp wrapper in WSL..."

# Create temp file path
$WslTempWrapper = "/tmp/claude-wrapper-$([guid]::NewGuid().ToString()).py"

# Build wrapper content
$WrapperContent = @"
#!/usr/bin/env python3
import sys
sys.argv = ['$WslScriptPath', '-y']

# Import and execute
with open('$WslScriptPath', 'r', encoding='utf-8') as f:
    exec(f.read())
"@

# Write wrapper to WSL temp file
$WrapperContent | wsl bash -c "cat > $WslTempWrapper && chmod +x $WslTempWrapper"

Write-Host "Running wrapper: $WslTempWrapper"
Write-Host ""

# Execute the temp wrapper
wsl python3 "$WslTempWrapper"

# Clean up
wsl rm -f "$WslTempWrapper"

Write-Host ""
Write-Host "Done - check prompt"
