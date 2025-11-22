[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [Guid]$ConfigurationId,
    [Parameter(Mandatory = $true)]
    [String]$PIDKEY
)

begin {
    [xml]$ConfigurationFile = New-Object -TypeName xml

    if (-not($ConfigurationId)) {
        [Guid]$ConfigurationId = New-Guid
    }

    if (-not($PIDKEY)) {
        [String]$PIDKEY = "V28N4-JG22K-W66P8-VTMGK-H6HGR"
    }
}

process {
    $ConfigurationFile = @"
<Configuration ID="$ConfigurationId">
<Add OfficeClientEdition="64" Channel="PerpetualVL2024" MigrateArch="TRUE">
<Product ID="Standard2024Volume" PIDKEY="$PIDKEY">
    <Language ID="MatchOS" />
    <Language ID="MatchPreviousMSI" />
    <ExcludeApp ID="OneDrive" />
    <ExcludeApp ID="OneNote" />
    <ExcludeApp ID="Outlook" />
    <ExcludeApp ID="PowerPoint" />
    <ExcludeApp ID="Publisher" />
</Product>
</Add>
<Property Name="SharedComputerLicensing" Value="0" />
<Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
<Property Name="DeviceBasedLicensing" Value="0" />
<Property Name="SCLCacheOverride" Value="0" />
<Property Name="AUTOACTIVATE" Value="1" />
<Updates Enabled="TRUE" />
<RemoveMSI />
<Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
"@    
}

end {
    return $ConfigurationFile
}
