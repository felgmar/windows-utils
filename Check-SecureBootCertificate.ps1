<#
.SYNOPSIS
    Checks whether the current "Windows UEFI CA 2023" Secure Boot certificate is
    installed, and offers to trigger Microsoft's update process if it isn't.

.DESCRIPTION
    Microsoft's original 2011 Secure Boot certificates began expiring in June 2026.
    Devices that have not received the replacement "Windows UEFI CA 2023" certificate
    will still start and run normally, but will stop receiving Secure Boot / Windows
    Boot Manager security updates going forward.

    This script:
      1. Confirms the device is using UEFI Secure Boot.
      2. Checks the live Secure Boot signature database (DB) for the 2023 certificate
         and cross-references Microsoft's servicing status registry keys.
      3. If the certificate is already present, reports that and exits - no changes made.
      4. If it isn't, warns the user and, only with explicit confirmation, sets the
         registry flag and kicks off Microsoft's built-in Secure-Boot-Update scheduled
         task, then explains that a restart is required to finish the process.

    No changes are made to the system unless you explicitly confirm the prompt.

.PARAMETER CheckOnly
    Only reports the current status; never prompts to install anything. Useful for
    monitoring / scripted checks.

.NOTES
    Must be run from an elevated (Administrator) PowerShell session.

    References:
      - Windows Secure Boot certificate expiration and CA updates
        https://support.microsoft.com/en-us/topic/windows-secure-boot-certificate-expiration-and-ca-updates
      - Registry key updates for Secure Boot: Windows devices with IT-managed updates (KB5068202)
        https://support.microsoft.com/en-us/topic/registry-key-updates-for-secure-boot-windows-devices-with-it-managed-updates
      - When Secure Boot certificates expire on Windows devices
        https://support.microsoft.com/en-us/topic/when-secure-boot-certificates-expire-on-windows-devices

.EXAMPLE
    .\Check-SecureBootCertificate.ps1

.EXAMPLE
    .\Check-SecureBootCertificate.ps1 -CheckOnly
#>

[CmdletBinding()]
param(
    [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'

function Write-Status { param([string]$Message) Write-Host $Message -ForegroundColor Cyan }
function Write-Ok { param([string]$Message) Write-Host $Message -ForegroundColor Green }
function Write-Warn2 { param([string]$Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Err2 { param([string]$Message) Write-Host $Message -ForegroundColor Red }

# ---------------------------------------------------------------------------
# 1. Must be elevated - registry writes under HKLM and the Secure Boot
#    cmdlets both require an Administrator session.
# ---------------------------------------------------------------------------
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentPrincipal = [Security.Principal.WindowsPrincipal]$currentIdentity
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Err2 "This script must be run from an elevated (Administrator) PowerShell session."
    Write-Err2 "Right-click PowerShell (or Windows Terminal) and choose 'Run as administrator', then try again."
    exit 1
}

# ---------------------------------------------------------------------------
# 2. Confirm this device actually uses UEFI Secure Boot.
# ---------------------------------------------------------------------------
$secureBootEnabled = $null
try {
    $secureBootEnabled = Confirm-SecureBootUEFI
}
catch {
    Write-Err2 "Could not query Secure Boot state: $($_.Exception.Message)"
    Write-Err2 "This usually means the device is running legacy BIOS instead of UEFI, or Secure Boot isn't supported on this hardware."
    exit 1
}

if (-not $secureBootEnabled) {
    Write-Warn2 "Secure Boot is currently DISABLED (or unsupported) on this device."
    Write-Warn2 "Microsoft recommends against leaving Secure Boot off, since it removes protection against boot-level malware."
    Write-Warn2 "Enable Secure Boot in your firmware (UEFI/BIOS) settings, then re-run this script to check certificate status."
    exit 1
}

# ---------------------------------------------------------------------------
# 3. Helper: read current certificate / servicing status.
# ---------------------------------------------------------------------------
function Get-SecureBootCA2023Info {
    $dbHasCA2023 = $null   # $true / $false / $null (indeterminate)
    $servicingStatus = $null   # NotStarted / InProgress / Updated / $null
    $servicingError = $null
    $availableUpdates = $null

    # Authoritative check: is "Windows UEFI CA 2023" actually present in the live
    # Secure Boot signature database (DB) that firmware is using right now?
    try {
        $dbVar = Get-SecureBootUEFI -Name db -ErrorAction Stop
        $dbText = [System.Text.Encoding]::ASCII.GetString($dbVar.Bytes)
        $dbHasCA2023 = $dbText -match 'Windows UEFI CA 2023'
    }
    catch {
        Write-Verbose "Could not read the Secure Boot DB directly: $($_.Exception.Message)"
    }

    # Supplementary info: Microsoft's own servicing status keys, present on builds
    # that received the November 2025 (or later) update (KB5068202).
    $servicingPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing'
    if (Test-Path -Path $servicingPath) {
        $svc = Get-ItemProperty -Path $servicingPath -ErrorAction SilentlyContinue
        if ($svc) {
            $servicingStatus = $svc.UEFICA2023Status
            $servicingError = $svc.UEFICA2023Error
        }
    }

    $mainPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot'
    if (Test-Path -Path $mainPath) {
        $main = Get-ItemProperty -Path $mainPath -ErrorAction SilentlyContinue
        if ($main -and ($null -ne $main.AvailableUpdates)) {
            $availableUpdates = '0x{0:X}' -f [int]$main.AvailableUpdates
        }
    }

    [PSCustomObject]@{
        DbHasCA2023      = $dbHasCA2023
        ServicingStatus  = $servicingStatus
        ServicingError   = $servicingError
        AvailableUpdates = $availableUpdates
    }
}

Write-Status "Checking Secure Boot certificate status..."
$info = Get-SecureBootCA2023Info

# ---------------------------------------------------------------------------
# 4. Already up to date?
# ---------------------------------------------------------------------------
$alreadyUpToDate = ($info.DbHasCA2023 -eq $true) -or ($info.ServicingStatus -eq 'Updated')

if ($alreadyUpToDate) {
    Write-Ok "The latest Secure Boot certificate (Windows UEFI CA 2023) is already installed on this device."
    if ($info.ServicingStatus) { Write-Ok "Servicing status: $($info.ServicingStatus)" }
    Write-Ok "No action needed."
    exit 0
}

if ($null -eq $info.DbHasCA2023) {
    Write-Warn2 "Could not directly read the Secure Boot signature database to confirm certificate presence."
    if ($info.ServicingStatus) {
        Write-Warn2 "Reported servicing status instead: $($info.ServicingStatus)"
    }
    else {
        Write-Warn2 "No servicing status registry keys were found either (this build may predate the relevant update)."
    }
}

# ---------------------------------------------------------------------------
# 5. Warn the user and, unless -CheckOnly, offer to install.
# ---------------------------------------------------------------------------
Write-Warn2 ""
Write-Warn2 "=============================================================="
Write-Warn2 " Secure Boot certificate update NOT detected on this device"
Write-Warn2 "=============================================================="
Write-Warn2 "Microsoft's original 2011 Secure Boot certificates began expiring in June 2026."
Write-Warn2 "Devices that have not moved to the new 'Windows UEFI CA 2023' certificate will"
Write-Warn2 "stop receiving Secure Boot and Windows Boot Manager security updates. The device"
Write-Warn2 "will keep starting and running normally, but will progressively lose protection"
Write-Warn2 "against new boot-level threats over time."
Write-Warn2 ""

if ($CheckOnly) {
    Write-Warn2 "Run this script without -CheckOnly if you'd like to be prompted to start the update."
    exit 2
}

$response = $null
while ($response -notin @('y', 'n')) {
    $response = (Read-Host "Do you want to trigger the Secure Boot certificate update now? (Y/N)").Trim().ToLower()
}

if ($response -eq 'n') {
    Write-Warn2 "No changes were made. You can wait for Windows Update to deploy this automatically,"
    Write-Warn2 "or re-run this script whenever you're ready to update."
    exit 2
}

# ---------------------------------------------------------------------------
# 6. Trigger the update.
# ---------------------------------------------------------------------------
Write-Status "Triggering the Secure Boot certificate update..."

try {
    $mainPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot'
    if (-not (Test-Path -Path $mainPath)) {
        New-Item -Path $mainPath -Force | Out-Null
    }
    # 0x5944 is Microsoft's documented value (KB5068202) for deploying the new 2023 CA
    # certificates, updating the KEK, and installing the new PCA2023-signed boot manager.
    New-ItemProperty -Path $mainPath -Name 'AvailableUpdates' -Value 0x5944 -PropertyType DWord -Force | Out-Null
    Write-Ok "  Update flag set (AvailableUpdates = 0x5944)."
}
catch {
    Write-Err2 "Failed to set the AvailableUpdates registry value: $($_.Exception.Message)"
    exit 1
}

try {
    Start-ScheduledTask -TaskName '\Microsoft\Windows\PI\Secure-Boot-Update' -ErrorAction Stop
    Write-Ok "  Update task started."
}
catch {
    Write-Warn2 "  Could not start the update task immediately: $($_.Exception.Message)"
    Write-Warn2 "  Windows will still pick this up on its own - the task normally runs every 12 hours."
}

Write-Status "Waiting briefly for an initial status update..."
Start-Sleep -Seconds 10
$info = Get-SecureBootCA2023Info
if ($info.ServicingStatus) { Write-Status "  Current servicing status: $($info.ServicingStatus)" }
if ($info.AvailableUpdates) { Write-Status "  AvailableUpdates flag now: $($info.AvailableUpdates)" }

# ---------------------------------------------------------------------------
# 7. Reboot notice.
# ---------------------------------------------------------------------------
Write-Warn2 ""
Write-Warn2 "=============================================================="
Write-Warn2 " A RESTART IS REQUIRED to finish this update"
Write-Warn2 "=============================================================="
Write-Warn2 "Adding the new certificates doesn't force a restart by itself, but the new"
Write-Warn2 "Secure Boot-signed Windows Boot Manager can only be installed after a reboot."
Write-Warn2 "Please save your work and restart this device. Afterward, you can run this"
Write-Warn2 "script again to confirm the update finished (status should read 'Updated')."
Write-Warn2 ""

$rebootResponse = $null
while ($rebootResponse -notin @('y', 'n')) {
    $rebootResponse = (Read-Host "Would you like to restart now? (Y/N)").Trim().ToLower()
}

if ($rebootResponse -eq 'y') {
    Write-Status "Restarting..."
    Restart-Computer -Force
}
else {
    Write-Status "Okay - just remember to restart manually before the update can fully take effect."
}
