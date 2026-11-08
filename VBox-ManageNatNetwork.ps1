<#
.SYNOPSIS
    Manages VirtualBox NAT Networks and their associated DHCP settings.

.DESCRIPTION
    This script allows you to start, stop, restart, modify subnets, enable/disable DHCP,
    and configure DHCP lease times for VirtualBox NAT Networks using VBoxManage.exe.

.PARAMETER Start
    Starts the specified NAT network.

.PARAMETER Stop
    Stops the specified NAT network.

.PARAMETER Restart
    Restarts the specified NAT network.

.PARAMETER SetNetwork
    Modifies the NAT network settings (requires -NetworkCIDR and/or -DHCP).

.PARAMETER SetDHCP
    Modifies the DHCP server settings (requires -LeaseTime and/or -DHCP).

.PARAMETER List
    Lists all active VirtualBox NAT networks.

.PARAMETER Help
    Displays help instructions and usage examples.
#>

[CmdletBinding(DefaultParameterSetName = "List")]
param (
    [Parameter(ParameterSetName = "Start", Mandatory = $true)]
    [switch]$Start,

    [Parameter(ParameterSetName = "Stop", Mandatory = $true)]
    [switch]$Stop,

    [Parameter(ParameterSetName = "Restart", Mandatory = $true)]
    [switch]$Restart,

    [Parameter(ParameterSetName = "SetNetwork", Mandatory = $true)]
    [switch]$SetNetwork,

    [Parameter(ParameterSetName = "SetDHCP", Mandatory = $true)]
    [switch]$SetDHCP,

    [Parameter(ParameterSetName = "List", Mandatory = $false)]
    [switch]$List,

    [Parameter(ParameterSetName = "Help", Mandatory = $true)]
    [Alias("h", "?")]
    [switch]$Help,

    [Parameter(ParameterSetName = "Start", Mandatory = $true)]
    [Parameter(ParameterSetName = "Stop", Mandatory = $true)]
    [Parameter(ParameterSetName = "Restart", Mandatory = $true)]
    [Parameter(ParameterSetName = "SetNetwork", Mandatory = $true)]
    [Parameter(ParameterSetName = "SetDHCP", Mandatory = $true)]
    [string]$NetName,

    [Parameter(ParameterSetName = "SetNetwork", Mandatory = $false)]
    [string]$NetworkCIDR,

    [Parameter(ParameterSetName = "SetNetwork", Mandatory = $false)]
    [Parameter(ParameterSetName = "SetDHCP", Mandatory = $false)]
    [ValidateSet("on", "off")]
    [string]$DHCP,

    [Parameter(ParameterSetName = "SetDHCP", Mandatory = $false)]
    [int]$LeaseTime
)

function Show-ScriptHelp {
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "             VirtualBox NAT Network Manager Help                  " -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Yellow
    Write-Host "  Manages VirtualBox NAT Networks and DHCP configurations using VBoxManage.exe."
    Write-Host ""
    Write-Host "USAGE / FLAGS:" -ForegroundColor Yellow
    Write-Host "  -Help, -h, -?                     Displays this help menu."
    Write-Host "  -List                             Lists all configured VirtualBox NAT networks."
    Write-Host "  -Start -NetName <Name>            Starts a NAT network."
    Write-Host "  -Stop -NetName <Name>             Stops a NAT network."
    Write-Host "  -Restart -NetName <Name>          Restarts a NAT network."
    Write-Host "  -SetNetwork -NetName <Name> ...   Configures CIDR/DHCP state for a NAT network."
    Write-Host "                                    [Flags: -NetworkCIDR <CIDR>, -DHCP <on|off>]"
    Write-Host "  -SetDHCP -NetName <Name> ...      Configures DHCP lease properties."
    Write-Host "                                    [Flags: -LeaseTime <Seconds>, -DHCP <on|off>]"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  1. Show help menu:" -ForegroundColor White
    Write-Host "     .\Manage-NatNetwork.ps1 -Help" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. List all NAT networks:" -ForegroundColor White
    Write-Host "     .\Manage-NatNetwork.ps1 -List" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Restart a NAT network:" -ForegroundColor White
    Write-Host "     .\Manage-NatNetwork.ps1 -Restart -NetName `"RickAndMorty`"" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  4. Modify network subnet CIDR and enable DHCP:" -ForegroundColor White
    Write-Host "     .\Manage-NatNetwork.ps1 -SetNetwork -NetName `"RickAndMorty`" -NetworkCIDR `"172.17.0.0/24`" -DHCP `"on`"" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  5. Set DHCP lease time to 10 minutes (600s):" -ForegroundColor White
    Write-Host "     .\Manage-NatNetwork.ps1 -SetDHCP -NetName `"RickAndMorty`" -LeaseTime 600" -ForegroundColor Gray
    Write-Host "==================================================================" -ForegroundColor Cyan
}

if ($Help) {
    Show-ScriptHelp
    exit 0
}

function Get-VBoxManagePath {
    $vboxCmd = Get-Command "VBoxManage.exe" -ErrorAction SilentlyContinue
    if ($vboxCmd) { return $vboxCmd.Source }

    $defaultPath = "${env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe"
    if (Test-Path $defaultPath) { return $defaultPath }

    Write-Error "VBoxManage.exe was not found. Please ensure VirtualBox is installed and added to system PATH."
    exit 1
}

$VBoxManage = Get-VBoxManagePath

if ($Start) {
    Write-Host "Starting NAT Network '$NetName'..." -ForegroundColor Green
    & $VBoxManage natnetwork start --netname $NetName
}
elseif ($Stop) {
    Write-Host "Stopping NAT Network '$NetName'..." -ForegroundColor Yellow
    & $VBoxManage natnetwork stop --netname $NetName
}
elseif ($Restart) {
    Write-Host "Restarting NAT Network '$NetName'..." -ForegroundColor Yellow
    & $VBoxManage natnetwork stop --netname $NetName 2>$null
    Start-Sleep -Seconds 2
    & $VBoxManage natnetwork start --netname $NetName
    Write-Host "NAT Network '$NetName' restarted successfully." -ForegroundColor Green
}
elseif ($SetNetwork) {
    $params = @("natnetwork", "modify", "--netname", $NetName)
    if ($NetworkCIDR) { $params += "--network"; $params += $NetworkCIDR }
    if ($DHCP)        { $params += "--dhcp";    $params += $DHCP }

    Write-Host "Updating NAT Network '$NetName'..." -ForegroundColor Cyan
    & $VBoxManage @params
    & $VBoxManage natnetwork stop --netname $NetName 2>$null
    Start-Sleep -Seconds 1
    & $VBoxManage natnetwork start --netname $NetName
}
elseif ($SetDHCP) {
    if ($LeaseTime) {
        Write-Host "Setting DHCP default lease time to $LeaseTime seconds for '$NetName'..." -ForegroundColor Cyan
        & $VBoxManage dhcpserver modify --network $NetName --default-lease-time $LeaseTime
    }
    if ($DHCP) {
        Write-Host "Setting DHCP state to '$DHCP' for NAT Network '$NetName'..." -ForegroundColor Cyan
        & $VBoxManage natnetwork modify --netname $NetName --dhcp $DHCP
    }
}
else {
    Write-Host "=== Active VirtualBox NAT Networks ===" -ForegroundColor Cyan
    & $VBoxManage list natnetworks
}