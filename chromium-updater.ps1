#
# Created by Felipe González Martín (felgmar)
# Chromium Update Tool
# chromium-updater.ps1 file
#

#requires -runasadministrator

${scriptVersion} = "1.0.2"
${programName} = 'Chromium'
${downloadUri} = 'https://download-chromium.appspot.com/dl/Win_x64?type=snapshots'
${zipFile} = 'chrome-win.zip'
${installDir} = "$env:ProgramFiles\The Chromium Project\Chromium"
${shortcutPath} = "$env:PUBLIC\Desktop"

function deleteChromium
{
    if (Test-Path -Path "${installDir}")
    {
        try
        {
            Write-Host "Deleting ${programName}..." -ForegroundColor Red
            Remove-Item -LiteralPath "${installDir}" -Force -Recurse -Verbose -ErrorAction Stop | Out-Null
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    else
    {
        Write-Error -Message "${programName} is not installed." -Category NotInstalled
    }

    if (Test-Path -Path "${env:USERPROFILE}\Desktop\Chromium.lnk")
    {
        try
        {
            Write-Host "Deleting shortcut..."
            Remove-Item -LiteralPath "${env:USERPROFILE}\Desktop\Chromium.lnk" -Force -Verbose -ErrorAction Stop | Out-Null
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    else
    {
        Write-Error -Message "Could not delete the desktop shortcut for ${programName}." -Category ResourceUnavailable
    }
}

function downloadChromium
{
    function GetFile
    {
        try
        {
            $null = Write-Progress "Downloading the latest Chromium win64 build..."
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri ${downloadUri} -OutFile ${env:TEMP}\${zipFile} -UseBasicParsing -ErrorAction Stop | Out-Null
            if (Test-Path -Path ${env:TEMP}\${zipFile} -PathType Leaf)
            {
                Write-Host "${programName} was downloaded successfully to ${env:TEMP}\${zipFile}"
            }
        }
        catch
        {
            throw $_.Exception.Message
        }
    }

    if (-not(Test-Path -Path ${env:TEMP}\${zipFile}))
    {
        GetFile
    }
    else
    {
        Write-Host ":: The file ${zipFile} already exists."
        $overwrite_file = Read-Host -Prompt "Do you want to download it again?"
        Switch ($overwrite_file)
        {
            'yes' {
                Write-Host ":: Deleting file ${env:TEMP}\${zipfile}..."
                Remove-Item -LiteralPath "${env:TEMP}\${zipFile}" -Force
                GetFile
            }
            'y' {
                Write-Host ":: Deleting file ${env:TEMP}\${zipfile}..."
                Remove-Item -LiteralPath "${env:TEMP}\${zipFile}" -Force
                GetFile
            }
        }
    }
}

function installChromium
{
    if (-not(Test-Path -Path "${installDir}"))
    {
        try {
            downloadChromium
            Write-Host ":: Installing ${programName} to ${installDir}"
            .\Unzip-File.ps1 -SourceFile "${env:TEMP}\${zipFile}" -DestinationPath "${installDir}"
            Move-Item -Path "${installDir}\chrome-win\*" -Destination "${installDir}"
            Remove-Item -Path "${installDir}\chrome-win"
        } catch {
            throw $_.Exception.Message
        }
        try
        {
            if (-not(Test-Path -LiteralPath ".\Create-Shortcut.ps1"))
            {
                Write-Error "Cannot create a shortcut." -Category ResourceUnavailable
            }
            .\Create-Shortcut.ps1 -ProgramName ${programName} -ShortcutPath "${shortcutPath}\Chromium.lnk" -TargetPath "${installDir}\chrome.exe" -WorkingDirectory "${installDir}"

            Write-Host "   ${programName} has been installed at ${installDir}"
            Write-Host "   A shortcut of Chromium has been created at ${shortcutPath}\Chromium.lnk"
            Start-Sleep 5
        }
        catch
        {
            $_.Exception.Message
        }
        Start-Sleep 5
    }
    else
    {
        Write-Error "${programName} is already installed in the directory ${installDir}"
        Start-Sleep 5
    }
}

function showMenu
{
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

do
{
    Clear-Host
    showMenu

    $option = Read-Host ":: Please select an option"
    Switch ($option)
    {
        '1'
        {
            installChromium
        }
        '2'
        {
            downloadChromium
        }
        '3'
        {
            deleteChromium
        }
    }
}
until ($option -eq "q")
