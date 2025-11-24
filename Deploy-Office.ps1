[String]$URL = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140"

[String]$InstallerDir = Join-Path -Path "$env:TEMP" -ChildPath "OfficeInstaller"
[String]$InstallerFileName = "officedeploymenttool_19231-20072.exe"
[String]$SetupFile = Join-Path -Path "$InstallerDir" -ChildPath "$InstallerFileName"

[String]$ConfigurationFile = Join-Path -Path "$InstallerDir" -ChildPath "Configuration.xml"

[Boolean]$IsInstallerDirPresent = Test-Path -Path "$InstallerDir"
[Boolean]$IsInstallerDirPresent = Test-Path -Path "$InstallerDir/$InstallerFileName"
[Boolean]$IsConfigurationFilePresent = Test-Path -Path "$ConfigurationFile"

[Guid]$ConfigurationId = ([System.GUID]::NewGuid()).Guid
[String]$PidKey = "V28N4-JG22K-W66P8-VTMGK-H6HGR"

if (-not($IsInstallerDirPresent)) {
    New-Item -Path "$InstallerDir" -Type Directory | Out-Null
}   

if (-not($IsConfigurationFilePresent)) {
    try {
        .\Create-XmlFile.ps1 -ConfigurationId "$ConfigurationId" -PIDKEY "$PidKey" | Out-File $ConfigurationFile
    }
    catch {
        throw $_.Exception
    }
}

if (-not(Test-Path -LiteralPath "$InstallerDir/$InstallerFileName")) {
    try {
        .\Download-File.ps1 -URL "$URL/$InstallerFileName" -OutputPath "$InstallerDir" -Filename "$InstallerFileName" -Verbose
    }
    catch {
        throw $_.Exception
    }
}

cd "$InstallerDir"

try {
    Write-Host "Extracting the Office installer..."
    Start-Process -FilePath "$SetupFile" -ArgumentList ("/extract:$InstallerDir", "/quiet", "/passive", "/log:$InstallerFileName.log")
}
catch {
    throw $_
}

try {
    Write-Host "Downloading Office..."
    Start-Process -FilePath "setup.exe" -ArgumentList ("/download", "$ConfigurationFile", "/log:$InstallerFileName_download.log")
}
catch {
    throw $_
}

try {
    $InstallNow = Read-Host "Do you want to install it now? [Y/N]"

    switch -Wildcard ($InstallNow.ToLower()) {
        'y*' {
            Write-Host "Installing Office..."
            Start-Process -FilePath "setup.exe" ("/configure", "$ConfigurationFile", "/log:$InstallerFileName_installation.log")
        }
        'yes*' {
            Write-Host "Installing Office..."
            Start-Process -FilePath "setup.exe" ("/configure", "$ConfigurationFile", "/log:$InstallerFileName_installation.log")
        }
        Default {
            Write-Host "Installation cancelled by the user."
            return
        }
    }
}
catch {
    throw $_
}

cd $PSScriptRoot
