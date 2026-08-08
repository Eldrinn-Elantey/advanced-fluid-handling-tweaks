@echo off
REM Packages the mod into build\<name>_<version>.zip with the folder layout Factorio expects.
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0release.ps1" %*
exit /b %ERRORLEVEL%
