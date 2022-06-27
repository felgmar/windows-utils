#
# Created by Ken Hoo (mrkenhoo)
# Chromium Update Tool
# chromium-updater.ps1 file
#

#Requires -Modules CreateShortcut, UnzipFile
#Requires -RunAsAdministrator

${programName} = 'Chromium'
${zipFile} = 'chrome-win.zip'
${installDir} = "$env:ProgramFiles\The Chromium Project"

function deleteChromium
{
    if (Test-Path -Path "${installDir}")
    {
        try
        {
            Write-Host "Deleting ${programName}..." -ForegroundColor Red
            Remove-Item -LiteralPath "${installDir}" -Force -Recurse -ErrorAction Stop | Out-Null
            Start-Sleep 5
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    else
    {
        Write-Error -Message "${programName} is not installed." -Category NotInstalled
        Start-Sleep 5
    }

    if (Test-Path -Path "${env:USERPROFILE}\Desktop\Chromium.lnk")
    {
        try
        {
            Write-Host "Deleting shortcut..."
            Remove-Item -LiteralPath "${env:USERPROFILE}\Desktop\Chromium.lnk" -Force -ErrorAction Stop | Out-Null
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    else
    {
        Write-Error -Message "Could not delete the desktop shortcut for ${programName}. It was not found." -Category ResourceUnavailable
        Start-Sleep 5
    }
}

function downloadChromium
{
    if (-not(Test-Path -Path ${env:TEMP}\${zipFile}))
    {
        try
        {
            $null = Write-Progress "Downloading the latest Chromium win64 build..."
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri https://download-chromium.appspot.com/dl/Win_x64?type=snapshots -OutFile ${env:TEMP}\${zipFile} -UseBasicParsing -ErrorAction Stop | Out-Null
            if (Test-Path -Path ${env:TEMP}\${zipFile} -PathType Leaf)
            {
                Write-Host "${programName} was downloaded successfully to ${env:TEMP}\${zipFile}"
            }
            Start-Sleep 5
        }
        catch
        {
            throw $_.Exception.Message
            Start-Sleep 5
        }
    }
    else
    {
        $redownload = Read-Host -Prompt ":: The file ${zipFile} already exists, do you want to download it again?"
        if ($redownload -eq "yes")
        {
            Write-Host ":: Deleting file ${env:TEMP}\${zipfile}..."
            Remove-Item -LiteralPath "${env:TEMP}\${zipFile}" -Force -ErrorAction Stop | Out-Null
            Start-Sleep 5
        }
        else
        {
            Write-Host ":: Operation cancelled"
            Start-Sleep 5
        }
    }
}

function installChromium
{
    if (-not(Test-Path -Path "${installDir}"))
    {
        Write-Progress "Extracting ${programName} to ${installDir}..."

        UnzipFile "${env:TEMP}\${zipFile}" "${installDir}"

        try
        {
            CreateShortcut -ProgramName ${programName} -ShortcutPath "${env:USERPROFILE}\Desktop\${programName}.lnk" -TargetPath "${installDir}\chrome-win\chrome.exe"

            Write-Host "${programName} has been installed at ${installDir}"
            Write-Host "A shortcut of Chromium has been created at ${env:USERPROFILE}\Desktop"
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
        [string]$Title = "Chromium Updater"
    )
    $option = null
    Clear-Host
    Write-Host ""
    Write-Host "================ $Title ================"
    Write-Host ""
    Write-Host "  > Type '1' to install Chromium"
    Write-Host "  > Type '2' to download/update Chromium"
    Write-Host "  > Type '3' to delete Chromium"
    Write-Host "  > Type 'Q' to quit"
    Write-Host ""
    Write-Host "=================================================="
}

do
{
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
