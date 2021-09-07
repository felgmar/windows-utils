@echo off
setlocal
set version=v20210826
title Windows CLI Installer Tool - %version%

goto check_permissions

:check_permissions
echo.Windows CLI Installer Tool - %version%
echo.

echo.:: Checking user permissions . . .
net session >nul 2>&1

if %errorlevel% == 0 (
    goto main
) else (
    echo.ERROR: You need Administrator privileges to use this tool.
    timeout /t 10 /nobreak
    exit 1
)

:main
(echo list disk) | diskpart
echo.
echo.
set /p disk=Specify the disk number to format: 

(echo list disk) | diskpart | find "Disk %disk%" >nul 2>&1

if errorlevel 1 (
    echo.
    echo.Error: Could not find disk %disk%, make sure it exists and try again.
    echo.
    timeout /t 5 /nobreak
    exit 
) else (
    goto disk_partitioning
)

:disk_partitioning
cls
echo.:: Partitioning disk %disk%, please wait...
(
    echo select disk %disk% 
    echo clean
    echo convert gpt
    echo create partition efi size=100
    echo select partition 2
    echo format fs=fat32 quick
    echo assign letter i
    echo create partition msr size=16
    echo create partition primary
    echo select partition 4
    echo format fs=ntfs quick
    echo assign letter j
) | diskpart >nul 2>&1

if errorlevel 1 (
    echo.
    echo.Error: Something ocurred during partitioning
    echo.
    pause
    exit 1
) else (
    goto check_installation_files
)

:check_installation_files
cls
echo.:: Where is the Windows installation disc mounted at?
set /p source_drive=Specify the drive letter [e.g. x:\]: 

if exist %source_drive%\sources\install.esd (
    dism /get-imageinfo /imagefile:%source_drive%\sources\install.esd
    goto install_esd
) else (
    echo.WARNING: Windows installation file "install.esd" not found, retrying with "install.wim"...
)

if exist %source_drive%\sources\install.wim (
    dism /get-imageinfo /imagefile:%source_drive%\sources\install.wim
    goto install_wim
) else (
    echo.ERROR: No valid Windows installation file was found, make sure the ISO is mounted and the source drive "%source_drive%\" is correct.
    timeout /5 /nobreak
    exit 1
)

:install_esd
echo.
echo.:: What edition of Windows are you looking for?
set /p windows_edition=Specify the index number: 
dism /apply-image /imagefile:%source_drive%\sources\install.esd /applydir:j:\ /index:%windows_edition% /verify
goto install_boot_files

:install_wim
echo.
echo.:: What edition of Windows are you looking for?
set /p windows_edition=Specify the index number: 
dism /apply-image /imagefile:%source_drive%\sources\install.wim /applydir:j:\ /index:%windows_edition% /verify
goto install_boot_files

:install_boot_files
echo.
bcdboot j:\windows /s i: /f UEFI /v
pause
