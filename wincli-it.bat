@echo off
setlocal
set version=v20210826
title Windows CLI Installer Tool - %version%

goto check_permissions

:check_permissions
echo.Windows CLI Installer Tool
echo.Version: %version%
echo.

echo.Checking user permissions . . .
net session >nul 2>&1

if %errorlevel% == 0 (
    goto main
) else (
    echo.
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
    echo.Error: Disk %Disk%: Invalid or non-existent disk
    echo.
    timeout /t 5 /nobreak
    exit 
) else (
    goto disk_partitioning
)

:disk_partitioning
cls
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
) | diskpart

if errorlevel 1 (
    echo.
    echo.Error: Something ocurred during partitioning
    echo.
    pause
    exit 1
) else (
    goto install
)
echo.

:install
cls
rem Ask the user for the desired Windows edition
set /p source_drive=Specify the drive letter where the Windows installation sources are located at [e.g.: X:\]: 
dism /get-imageinfo /imagefile:%source_drive%\sources\install.wim
echo.
set /p windows_edition=Select the edition (e.g. index number: 2) you want to install: 

rem Apply the Windows image file to the primary partition in J:\
dism /apply-image /imagefile:%source_drive%\sources\install.wim /applydir:j:\ /index:%windows_edition% /verify

rem Install boot files to EFI partition in Z:
echo.
bcdboot j:\windows /s i: /f UEFI /v
pause
