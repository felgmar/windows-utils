@echo off
setlocal
chcp 65001
set version=v20211212
color a
title Windows CLI Installer Tool - %version%

:choose_language
cls
echo.Windows CLI Installer Tool - %version%
echo.
echo.============ MAIN MENU ============
echo.=                                 =
echo.=   Available languages           =
echo.=                                 =
echo.=      1) English                 =
echo.=      2) Spanish                 =
echo.=                                 =
echo.=      0) Quit                    =
echo.=                                 =
echo.===================================
echo.
set lang=
set /p lang=:: Choose your language: 
if /i '%lang%'=='1' goto set_lang_vars_en
if /i '%lang%'=='2' goto set_lang_vars_es
if /i '%lang%'=='0' exit
echo.
echo.:: ERROR: '%lang%': Invalid or unknown language. Try again.
pause >nul 2>&1
cls
goto choose_language

:set_lang_vars_en
set chk_usr_perms=:: Checking user permissions ...
set err_no_admin_perms=:: ERROR: You need Administrator privileges to use this tool.
set find_disk=find "Disk %disk%"
set err_disk_not_found=:: ERROR: Could not find disk %disk%, make sure it exists and try again.
set chck_lang=:: INFO: Check the language selected is the right one.
set part_disk_wait=:: Partitioning disk %disk%, please wait . . .
set err_on_part=:: ERROR: Something ocurred during partitioning
set iso_mnt_location=:: Specify the drive where the ISO is mounted at (e.g. Z:\): 
set err_esd_not_found=:: WARNING: Windows installation file "install.esd" not found, retrying with "install.wim"...
set err_valid_install_file_found=:: ERROR: No valid Windows installation file was found, make sure the ISO is mounted and the source drive "%source_drive%" is correct.
set sel_win_edition=:: Select the Windows edition you want to install: 
set installation_ended=:: Windows is now installed, reboot and choose to boot from disk "%disk%" to start using it.
goto check_permissions

:set_lang_vars_es
set chk_usr_perms=:: Comprobando los permisos del usuario . . .
set err_no_admin_perms=:: ERROR: Necesitas privilegios de Administrador para usar esta herramienta.
set find_disk=find "Disco %disk%"
set err_disk_not_found=:: ERROR: No se pudo encontrar el disco %disk%, comprueba que existe y prueba de nuevo.
set chck_lang=:: INFO: Comprueba que el idioma seleccionado es el correcto.
set part_disk_wait=:: Particionando disco %disk%, por favor espera . . .
set err_on_part=:: ERROR: Ha ocurrido algo durante el particionado
set iso_mnt_location=:: Especifica la unidad en la que se encuentra la ISO montada (por ejemplo: Z:\): 
set err_esd_not_found=:: AVISO: El archivo de instalación de Windows "install.esd" no se ha encontrado, probando con "install.wim"...
set err_no_valid_installation_file_found=:: ERROR: No se ha encontrado un archivo de instalación de Windows válido, comprueba que la ISO está montada y el dispositivo de origen "%source_drive%" es correcto.
set sel_win_edition=:: Selecciona la edición de Windows que quieres instalar: 
set installation_ended=:: Windows ahora está instalado, reinicia y elige arrancar desde el disco "%disk%" para empezar a usarlo.
goto check_permissions

:check_permissions
cls
echo.Windows CLI Installer Tool - %version%
echo.
echo.%chk_usr_perms%
net session >nul 2>&1

if %errorlevel% == 0 (
    if %lang% == 1 (
        goto main_en
    ) else if %lang% == 2 (
            goto main_es
        )
    )
) else (
    cls
    echo.%err_no_admin_perms%
    timeout /t 10 /nobreak
    exit 1
)

:main_en
(echo list disk) | diskpart
echo.
echo.
set disk=
set /p disk=:: Specify the disk number to format: 

if errorlevel 1 (
    echo.
    echo.%err_disk_not_found%
    echo.%chck_lang%
    echo.
    timeout /t 5 /nobreak
    exit 
) else (
    goto disk_partitioning
)

:main_es
(echo list disk) | diskpart
echo.
echo.
set disk=
set /p disk=:: Especifica el número del disco para formatearlo: 

(echo list disk) | diskpart | %find_disk% >nul 2>&1

if errorlevel 1 (
    echo.
    echo.%err_disk_not_found%
    echo.%chck_lang%
    echo.
    timeout /t 5 /nobreak
    exit 
) else (
    goto disk_partitioning
)

:disk_partitioning
cls
echo.Windows CLI Installer Tool - %version%
echo.
echo.%part_disk_wait%
(
    echo select disk %disk% 
    echo clean
    echo convert gpt
    echo create partition efi size=100
    echo format fs=fat32 quick
    echo assign letter i
    echo create partition primary
    echo format fs=ntfs quick
    echo assign letter j
) | diskpart >nul 2>&1

if errorlevel 1 (
    echo.
    echo.%error_on_part%
    echo.
    pause
    exit 1
) else (
    goto check_installation_files
)

:check_installation_files
cls
echo.Windows CLI Installer Tool - %version%
echo.
set /p source_drive="%iso_mnt_location%"

if exist %source_drive%\sources\install.esd (
    dism /get-imageinfo /imagefile:%source_drive%\sources\install.esd
    goto install_esd
) else (
    echo.%err_esd_not_found%
)

if exist %source_drive%\sources\install.wim (
    dism /get-imageinfo /imagefile:%source_drive%\sources\install.wim
    goto install_wim
) else (
    echo.%err_no_valid_installation_file_found%
    timeout /5 /nobreak
    exit 1
)

:install_esd
echo.
set /p windows_edition="%sel_win_edition%"
dism /apply-image /imagefile:%source_drive%\sources\install.esd /applydir:j:\ /index:%windows_edition% /verify
goto install_boot_files

:install_wim
echo.
set /p windows_edition="%sel_win_edition%"
dism /apply-image /imagefile:%source_drive%\sources\install.wim /applydir:j:\ /index:%windows_edition% /verify
goto install_boot_files

:install_boot_files
echo.
bcdboot j:\windows /s i: /f UEFI /v
pause >nul 2>&1

if errorlevel 1 (
    echo.An error ocurred
) else (
    goto install_finished
)

:install_finished
cls
echo.%installation_ended%
pause >nul 2>&1
exit
