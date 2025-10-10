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
            [String]$PIDKEY
        )

        return @"
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
"@
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
            New-Item -Path "$OutputPath" -ItemType "Directory"
        }

        if (-not(Test-Path -LiteralPath "$OutFile")) {
            try {
                Invoke-WebRequest -Uri $URL -OutFile $OutFile
            }
            catch {
                throw $_.Exception.Message
            }
        } else {
            Write-Warning "File $OutFile already exists."
        }
        return $ERRORLEVEL
    }

    [String]$Filename = "officedeploymenttool_19231-20072.exe"
    [String]$URL = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/$Filename"
    [String]$Path = Join-Path -Path "$env:TEMP" -ChildPath "OfficeInstaller"
    [String]$SetupBinary = Join-Path -Path "$Path" -ChildPath "$Filename"
    $ConfigurationFile = CreateXmlFile -PIDKEY "V28N4-JG22K-W66P8-VTMGK-H6HGR"

    [Boolean]$IsXmlFilePresent = Test-Path -Path (Join-Path -Path $Path -ChildPath "Configuration.xml")

    if (-not(Test-Path -Path "$Path")) {
        New-Item -Path "$Path" -Type Directory | Out-Null
    }
    

    if (-not(Test-Path -LiteralPath "$Path\Configuration.xml")) {
        Set-Content -Value $ConfigurationFile -Path "$Path\Configuration.xml" -Verbose
    }

    try {
        DownloadFile -URL "$URL" -OutputPath "$Path" -Filename "$Filename" -Verbose
    } catch {
        throw $_.Exception
    }

    try {
        Write-Host "Extracting the Office installer..."
        powershell.exe -Command "& {cd $Path; .\$Filename /extract:$Path /quiet /passive /log:$SetupBinary.log; cd ..}"
    } catch {
        throw $_.Exception
    }

    try {
        Write-Host "Downloading Office..."
        powershell.exe -Command "& {cd $Path; .\setup.exe /download .\Configuration.xml; cd ..}"
    } catch {
        throw $_.Exception
    }

    try {
        $InstallNow = Read-Host "Do you want to install it now? [Y/N]"

        switch -Wildcard ($InstallNow.ToLower()) {
            'y*' {
                Write-Host "Installing Office"
                powershell.exe -Command "& {cd $Path; .\setup.exe /configure .\Configuration.xml; cd $PScriptRoot}"
            }
            'yes*' {
                Write-Host "Installing Office"
                powershell.exe -Command "& {cd $Path; .\setup.exe /configure .\Configuration.xml; cd $PScriptRoot}"
            }
            Default {
                Write-Host "Installation cancelled by the user."
                return
            }
        }
    } catch {
        throw $_.Exception
    }
}
