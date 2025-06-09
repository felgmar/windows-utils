[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$ConfigurationFile,
    [Parameter(Mandatory=$true)]
    [String]$ProductKey
)

process {
    function CreateXmlFile() {
        param(
            [Parameter(Mandatory=$true)]
            [String]$DestinationPath,
            [Parameter(Mandatory=$true)]
            [String]$PIDKEY
        )
        @"
<Configuration ID="ce714996-a823-42f4-8150-3cbf8b2e709e">
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
"@ | Set-Content -Path (Join-Path -Path "$DestinationPath" -ChildPath "Configuration.xml")
    }

    function DownloadFile() {
        param(
            [Parameter(Mandatory=$true)]
            [String]$URL,
            [Parameter(Mandatory=$true)]
            [String]$OutputPath,
            [Parameter(Mandatory=$true)]
            [String]$Filename
        )

        [Boolean]$IsURLEmpty        = [string]::IsNullOrWhiteSpace($URL)
        [Boolean]$IsOutputPathEmpty = [string]::IsNullOrWhiteSpace($OutputPath)
        [String]$OutFile            = Join-Path -Path "$OutputPath" -ChildPath "$Filename"

        if ($IsURLEmpty) {
            throw "No URL"
        }
        if ($IsOutputPathEmpty) {
            throw "No output path"
        }
        if (Test-Path -Path "$OutputPath") {
            Write-Warning "$OutputPath already exists."
        } else {
            New-Item -Path "$OutputPath" -ItemType "Directory" -WarningAction Stop -ErrorAction Stop
        }

        if (-not(Test-Path -LiteralPath "$OutFile")) {
            try {
                Start-BitsTransfer -Source $URL `
                    -Destination $OutFile `
                    -DisplayName "Downloading $Filename..."
            }
            catch {
                throw $_.Exception.Message
            }
        } else {
            Write-Warning "File $OutFile already exists."
        }
        return $ERRORLEVEL
    }

    [String]$Filename = "officedeploymenttool_18730-20142.exe"
    [String]$URL = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/$Filename"
    [String]$Path = Join-Path -Path "$env:TEMP" -ChildPath "OfficeInstaller"
    [String]$SetupBinary = Join-Path -Path "$Path" -ChildPath "$Filename"

    if (-not($ConfigurationFile)) {
        CreateXmlFile -DestinationPath "$Path" -PIDKEY $ProductKey
    }

    try {
        DownloadFile -URL "$URL" -OutputPath "$Path" -Filename "$Filename"
    } catch {
        throw $_.Exception
    }

    try {
        powershell.exe -Command "& {cd $Path; .\$Filename /extract:$Path /quiet /passive /log:$SetupBinary.log; cd ..}"
    } catch {
        throw $_.Exception
    }

    try {
        if (-not((Join-Path -Path "$Path" -ChildPath "Office"))) {
            powershell.exe -Command "& {cd $Path; .\setup.exe /download $ConfigurationFile; cd ..}"
        } else {
            Write-Warning "Office is already downloaded."
        }
    } catch {
        throw $_.Exception.Message
    }

    try {
        $InstallNow = Read-Host "Do you want to install it now? [Y/N]"

        switch -Wildcard ($InstallNow.ToLower()) {
            'y*' {
                powershell.exe -Command "& {cd $Path; .\setup.exe /configure $ConfigurationFile; cd ..}"
            }
            'yes*' {
                powershell.exe -Command "& {cd $Path; .\setup.exe /configure $ConfigurationFile; cd ..}"
            }
            Default {
                Write-Host "Installation cancelled by the user."
                return
            }
        }
    } catch {
        throw $_.Exception.Message
    }
}
