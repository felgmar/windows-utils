[String]$URL = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140"

[String]$InstallerDir = Join-Path -Path "$env:TEMP" -ChildPath "OfficeInstaller"
[String]$InstallerFileName = "officedeploymenttool_19231-20072.exe"
[String]$SetupFile = Join-Path -Path "$InstallerDir" -ChildPath "$InstallerFileName"

[String]$ConfigurationFile = Join-Path -Path "$InstallerDir" -ChildPath "Configuration.xml"

[Boolean]$IsInstallerDirPresent = Test-Path -Path "$InstallerDir"
[Boolean]$IsConfigurationFilePresent = Test-Path -Path "$ConfigurationFile"

[Guid]$ConfigurationId = [System.Guid]::NewGuid()
[String]$PidKey = "V28N4-JG22K-W66P8-VTMGK-H6HGR"

if (-not($IsInstallerDirPresent)) {
    New-Item -Path "$InstallerDir" -Type Directory | Out-Null
}   

if (-not($IsConfigurationFilePresent)) {
    .\Create-XmlFile.ps1 -ConfigurationId "$ConfigurationId" -PIDKEY "$PidKey"
}

try {
    .\Download-File.ps1 -URL "$URL/$InstallerFileName" -OutputPath "$InstallerDir" -Filename "$InstallerFileName" -Verbose
}
catch {
    throw $_.Exception
}

try {
    Write-Host "Extracting the Office installer..."
    powershell.exe -Command "& {cd $InstallerDir; .\$SetupFile /extract:$InstallerDir /quiet /passive /log:$InstallerFileName.log; cd ..}"
}
catch {
    throw $_.Exception
}

try {
    Write-Host "Downloading Office..."
    powershell.exe -Command "& {cd $InstallerDir; .\setup.exe /download .\$ConfigurationFile; cd ..}"
}
catch {
    throw $_.Exception
}

try {
    $InstallNow = Read-Host "Do you want to install it now? [Y/N]"

    switch -Wildcard ($InstallNow.ToLower()) {
        'y*' {
            Write-Host "Installing Office..."
            powershell.exe -Command "& {cd $InstallerDir; .\setup.exe /configure .\$ConfigurationFile; cd $PScriptRoot}"
        }
        'yes*' {
            Write-Host "Installing Office..."
            powershell.exe -Command "& {cd $InstallerDir; .\setup.exe /configure .\$ConfigurationFile; cd $PScriptRoot}"
        }
        Default {
            Write-Host "Installation cancelled by the user."
            return
        }
    }
}
catch {
    throw $_.Exception
}
