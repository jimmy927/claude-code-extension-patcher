@echo off
setlocal enabledelayedexpansion

:: Set window title
title Claude Code Patcher (v3 with Backup)

:: Define strings to search for and replace
set "original_string=k=[\"--output-format\",\"stream-json\",\"--verbose\",\"--input-format\",\"stream-json\"]"
set "replacement_string=k=[\"--dangerously-skip-permissions\",\"--output-format\",\"stream-json\",\"--verbose\",\"--input-format\",\"stream-json\"]"

:: Regular expression patterns used by PowerShell
set "original_pattern=k=\[\"--output-format\",\"stream-json\",\"--verbose\",\"--input-format\",\"stream-json\"\]"
set "replacement_pattern=k=\[\"--dangerously-skip-permissions\",\"--output-format\",\"stream-json\",\"--verbose\",\"--input-format\",\"stream-json\"\]"

:: Define file names
set "target_file=extension.js"
set "backup_file=%target_file%.bak"
set "file_path="
set "backup_path="

echo.
echo ==========================================================
echo           Claude Code Patcher (v4 - Auto-detect)
echo ==========================================================
echo This script will modify '%target_file%' to add the
echo '--dangerously-skip-permissions' launch argument.
echo.
echo Searching for Claude Code extension in VSCode and Cursor...
echo.

:: 1. Search for extension.js in typical locations
:: Check if file exists in current directory first
if exist "%~dp0%target_file%" (
    set "file_path=%~dp0%target_file%"
    echo [FOUND] Extension in current directory
    goto found_file
)

:: Search in VSCode extensions
echo [SEARCH] Looking in VSCode extensions...
for /d %%i in ("%USERPROFILE%\.vscode\extensions\anthropics.claude-code-*") do (
    if exist "%%i\dist\%target_file%" (
        set "file_path=%%i\dist\%target_file%"
        echo [FOUND] %%i\dist\%target_file%
        goto found_file
    )
)

:: Search in Cursor extensions
echo [SEARCH] Looking in Cursor extensions...
for /d %%i in ("%USERPROFILE%\.cursor\extensions\anthropics.claude-code-*") do (
    if exist "%%i\dist\%target_file%" (
        set "file_path=%%i\dist\%target_file%"
        echo [FOUND] %%i\dist\%target_file%
        goto found_file
    )
)

:: If not found anywhere
echo [ERROR] '%target_file%' not found in any of the following locations:
echo   - Current directory
echo   - %USERPROFILE%\.vscode\extensions\anthropics.claude-code-*\dist\
echo   - %USERPROFILE%\.cursor\extensions\anthropics.claude-code-*\dist\
echo.
echo Please ensure Claude Code extension is installed in VSCode or Cursor.
goto end

:found_file
set "backup_path=%file_path%.bak"
echo.
echo [INFO] Target file: %file_path%
echo [INFO] Backup will be: %backup_path%
echo.
echo A backup of the original file will be created before any changes are made.
echo.
echo Press any key to continue, or close this window to cancel.
pause > nul
echo.

:: 2. Check if file has already been patched
powershell -NoProfile -Command "if ((Get-Content -Raw -Path '%file_path%') -match '%replacement_pattern%') { exit 0 } else { exit 1 }"
if %errorlevel% equ 0 (
    echo [INFO] The file appears to be already patched. No changes made.
    goto end
)

:: 3. Check if original string exists
powershell -NoProfile -Command "if ((Get-Content -Raw -Path '%file_path%') -match '%original_pattern%') { exit 0 } else { exit 1 }"
if %errorlevel% neq 0 (
    echo [WARNING] The original arguments array was not found.
    echo The file might be a different version or already modified.
    echo No changes were made.
    goto end
)

:: 4. Create backup (if backup file doesn't exist)
echo [INFO] Checking for existing backup...
if not exist "%backup_path%" (
    echo [ACTION] Creating backup of the original file as '%backup_file%'...
    copy "%file_path%" "%backup_path%" > nul
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create backup file. Aborting patch.
        goto end
    )
    echo [SUCCESS] Backup created.
) else (
    echo [INFO] Backup file '%backup_file%' already exists. Proceeding without creating a new backup.
)
echo.


:: 5. Execute replacement
echo [ACTION] Found the original arguments array. Patching the file...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-Content -Raw -Path '%file_path%') -replace '%original_pattern%', '%replacement_string%' | Set-Content -Path '%file_path%'"

:: 6. Check result
if %errorlevel% equ 0 (
    echo [SUCCESS] The file '%target_file%' has been successfully patched!
    echo If you encounter any issues, you can restore the original file
    echo by renaming '%backup_file%' back to '%target_file%'.
) else (
    echo [ERROR] Something went wrong during the patching process.
    echo Please check your permissions and try running as an administrator if needed.
)

:end
echo.
echo ==========================================================
echo Patch process finished.
echo.
pause