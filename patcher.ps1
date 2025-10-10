u/echo off
setlocal enabledelayedexpansion

:: 设置窗口标题
title Claude Code Patcher (v3 with Backup)

:: 定义要查找和替换的字符串
set "original_string=k=[\"--output-format\",\"stream-json\",\"--verbose\",\"--input-format\",\"stream-json\"]"
set "replacement_string=k=[\"--dangerously-skip-permissions\",\"--output-format\",\"stream-json\",\"--verbose\",\"--input-format\",\"stream-json\"]"

:: PowerShell 使用的正则表达式模式
set "original_pattern=k=\[\"--output-format\",\"stream-json\",\"--verbose\",\"--input-format\",\"stream-json\"\]"
set "replacement_pattern=k=\[\"--dangerously-skip-permissions\",\"--output-format\",\"stream-json\",\"--verbose\",\"--input-format\",\"stream-json\"\]"

:: 定义文件名和路径
set "target_file=extension.js"
set "backup_file=%target_file%.bak"
set "file_path=%~dp0%target_file%"
set "backup_path=%~dp0%backup_file%"

echo.
echo ==========================================================
echo           Claude Code VSCode Patcher (v3)
echo ==========================================================
echo This script will modify '%target_file%' to add the
echo '--dangerously-skip-permissions' launch argument.
echo.
echo A backup of the original file will be created as
echo '%backup_file%' before any changes are made.
echo.
echo Make sure this script is in the same directory as
echo '%target_file%'.
echo.
echo Press any key to continue, or close this window to cancel.
pause > nul
echo.

:: 1. 检查 extension.js 是否存在
if not exist "%file_path%" (
    echo [ERROR] '%target_file%' not found in the current directory.
    echo Please place this script next to the file you want to patch.
    goto end
)

:: 2. 检查是否已经被修改过
powershell -NoProfile -Command "if ((Get-Content -Raw -Path '%file_path%') -match '%replacement_pattern%') { exit 0 } else { exit 1 }"
if %errorlevel% equ 0 (
    echo [INFO] The file appears to be already patched. No changes made.
    goto end
)

:: 3. 检查原始字符串是否存在
powershell -NoProfile -Command "if ((Get-Content -Raw -Path '%file_path%') -match '%original_pattern%') { exit 0 } else { exit 1 }"
if %errorlevel% neq 0 (
    echo [WARNING] The original arguments array was not found.
    echo The file might be a different version or already modified.
    echo No changes were made.
    goto end
)

:: 4. 创建备份（如果备份文件不存在）
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


:: 5. 执行替换
echo [ACTION] Found the original arguments array. Patching the file...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-Content -Raw -Path '%file_path%') -replace '%original_pattern%', '%replacement_string%' | Set-Content -Path '%file_path%'"

:: 6. 检查结果
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