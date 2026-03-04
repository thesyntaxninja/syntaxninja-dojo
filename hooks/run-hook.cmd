: ; # Polyglot script — runs as bash on Unix, cmd.exe on Windows
: ; SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
: ; exec bash "$SCRIPT_DIR/$1" "${@:2}"
: ; exit
@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%") do set "SCRIPT_DIR=%%~fI"
where bash >nul 2>nul
if %errorlevel%==0 (
    bash "%SCRIPT_DIR%\%1" %2 %3 %4 %5 %6 %7 %8 %9
) else (
    for /f "tokens=*" %%i in ('where git') do set "GIT_PATH=%%~dpi"
    "%GIT_PATH%..\bin\bash.exe" "%SCRIPT_DIR%\%1" %2 %3 %4 %5 %6 %7 %8 %9
)
