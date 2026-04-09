@echo off
echo Creating symlink for pve_challenge mod...
echo This script must be run as Administrator.
echo.

set DOTA_ADDONS="C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons"
set TARGET="C:\git\DotaModHelper\pve_challenge"

if exist %DOTA_ADDONS%\pve_challenge (
    echo Removing existing pve_challenge entry...
    rmdir %DOTA_ADDONS%\pve_challenge
)

mklink /J %DOTA_ADDONS%\pve_challenge %TARGET%

if %errorlevel% == 0 (
    echo Success! Symlink created.
) else (
    echo Failed. Make sure you are running as Administrator.
)
pause
