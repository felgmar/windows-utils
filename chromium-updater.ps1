[Security.Principal.WindowsPrincipal]$Principal = [Security.Principal.WindowsIdentity]::GetCurrent()
[Security.Principal.WindowsBuiltInRole]$Administrator = [Security.Principal.WindowsBuiltInRole]::Administrator
[System.Boolean]$IsAdmin = $Principal.IsInRole($Administrator)

[String]$ScriptVersion = "1.1.0"
[String]$ProgramName = 'Chromium'
[String]$DownloadUri = 'https://download-chromium.appspot.com/dl/Win_x64?type=snapshots'
[String]$ZipFile = 'chrome-win.zip'

if ($IsAdmin) {
    [String]$InstallDir = "$env:ProgramFiles\The Chromium Project\Chromium"
    [String]$ShortcutPath = "$env:PUBLIC\Desktop"
}
else {
    [String]$InstallDir = "$env:LOCALAPPDATA\Programs\The Chromium Project\Chromium"
    [String]$ShortcutPath = "$env:USERPROFILE\Desktop"
}

[System.Boolean]$IsChromiumInstalled = Test-Path -Path "$InstallDir"

function Remove-Chromium {
    if (-not($IsChromiumInstalled)) {
        throw "Cannot uninstall $ProgramName because it is not installed."
    }

    try {
        Write-Host "Deleting $ProgramName..." -ForegroundColor Red
        Remove-Item -LiteralPath "$InstallDir" -Force -Recurse -Verbose -ErrorAction Stop | Out-Null
    }
    catch {
        throw $_
    }

    [System.Boolean]$IsShortcutPresent = Test-Path -Path "$ShortcutPath\Chromium.lnk"

    if ($IsShortcutPresent) {
        try {
            Write-Host "Deleting shortcut..."
            Remove-Item -LiteralPath "$env:USERPROFILE\Desktop\Chromium.lnk" -Force -Verbose -ErrorAction Stop | Out-Null
        }
        catch {
            throw $_
        }
    }
    else {
        Write-Error -Message "Could not delete the desktop shortcut for $ProgramName." -Category ResourceUnavailable
    }
}

function Get-Chromium {
    function Get-File {
        try {
            $null = Write-Progress "Downloading the latest Chromium win64 build..."
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri ${downloadUri} -OutFile ${env:TEMP}\$ZipFile -UseBasicParsing -ErrorAction Stop | Out-Null
            if (Test-Path -Path ${env:TEMP}\$ZipFile -PathType Leaf) {
                Write-Host "$ProgramName was downloaded successfully to ${env:TEMP}\$ZipFile"
            }
        }
        catch {
            throw $_.Exception.Message
        }
    }

    [System.Boolean]$ZipFileExists = Test-Path -Path "${env:TEMP}\$ZipFile"

    if (-not($ZipFileExists)) {
        try {
            Get-File
        }
        catch {
            throw $_
        }
    }
    else {
        Write-Warning "The file $ZipFile already exists."
        $ShouldOverwriteFile = Read-Host -Prompt "  Do you want to download it again? [Y/N]"
        Switch -Wildcard ($ShouldOverwriteFile.ToLower()) {
            'y*' {
                Write-Host ":: Deleting file ${env:TEMP}\$ZipFile..."
                Remove-Item -LiteralPath "${env:TEMP}\$ZipFile" -Force
                Get-File
                break
            }
            'Y*' {
                Write-Host ":: Deleting file ${env:TEMP}\$ZipFile..."
                Remove-Item -LiteralPath "${env:TEMP}\$ZipFile" -Force
                Get-File
                break
            }
            default {
                Write-Host ":: File download cancelled."
                break
            }
        }
    }
}

function Install-Chromium {
    if (-not($IsChromiumInstalled)) {
        try {
            Get-Chromium
            Write-Host ":: Installing $ProgramName to $InstallDir"
            .\Unzip-File.ps1 -SourceFile "${env:TEMP}\$ZipFile" -DestinationPath "$InstallDir"
            Move-Item -Path "$InstallDir\chrome-win\*" -Destination "$InstallDir"
            Remove-Item -Path "$InstallDir\chrome-win"
        }
        catch {
            throw $_
        }

        try {
            if (-not(Test-Path -LiteralPath ".\Create-Shortcut.ps1")) {
                throw "Cannot create a shortcut, Create-Shortcut.ps1 does not exist."
            }
            .\Create-Shortcut.ps1 -ProgramName "$ProgramName" -ShortcutPath "$ShortcutPath\Chromium.lnk" -TargetPath "$InstallDir\chrome.exe" -WorkingDirectory "$InstallDir"

            Write-Host "   $ProgramName has been installed at $InstallDir"
            Write-Host "   A shortcut of Chromium has been created at $ShortcutPath\Chromium.lnk"
        }
        catch {
            $_.Exception.Message
        }

        Start-Sleep 5
    }
    else {
        Write-Error "$ProgramName is already installed in the directory $InstallDir"
        Start-Sleep 5
    }
}

function Show-Menu {
    param
    (
        [string]$Title = "Chromium Updater - v$ScriptVersion"
    )
    Write-Host "================ $Title ================"
    Write-Host ""
    Write-Host "  > Type '1' to install Chromium"
    Write-Host "  > Type '2' to download/update Chromium"
    Write-Host "  > Type '3' to delete Chromium"
    Write-Host "  > Type 'Q' to quit"
    Write-Host ""
    Write-Host "==========================================================="
}

do {
    Clear-Host
    Show-Menu

    $option = Read-Host ":: Please select an option"
    Switch ($option) {
        '1' {
            try {
                Install-Chromium
            }
            catch {
                throw $_
            }
        }
        '2' {
            try {
                Get-Chromium
            }
            catch {
                throw $_
            }
        }
        '3' {
            try {
                Remove-Chromium
            }
            catch {
                throw $_
            }
        }
    }
}
until ($option -eq "q")
