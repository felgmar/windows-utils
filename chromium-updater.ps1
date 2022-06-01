#
# Created by Ken Hoo (mrkenhoo)
# Chromium Update Tool
# chromium-updater.ps1 file
#
Add-Type -AssemblyName System.IO.Compression.FileSystem
${WShell} = New-Object -ComObject Wscript.Shell
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
        Switch ([System.Windows.Forms.MessageBox]::Show("This script needs Administrator privileges to run. Do you want to give permissions to this script?", "Insufficient permissions", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)) {
        Yes {
            Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        }
        No {
            Write-Error "This script needs administrator privileges to work, try again."
            Start-Sleep 5
            Exit 1
        }
    }
}

$programName = 'Chromium'
$zipFile = 'chrome-win.zip'
$installDir = "$env:ProgramFiles\The Chromium Project"

function unzipFile {
    #
    # Function source:
    # 'https://stackoverflow.com/questions/27768303/how-to-unzip-a-file-in-powershell'
    #
    param([string]$zipFile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $outpath)
}


function deleteChromium
{
    if (Test-Path -Path "$installDir")
    {
        try
        {
            Write-Host "Looks like Chromium is already installed, removing it..."
            Remove-Item -LiteralPath "$installDir" -Force -Recurse | Out-Null
        }
        catch
        {
            throw $_.Exception.Message
        }
    }

    if (Test-Path -Path "$env:USERPROFILE\Desktop\Chromium.lnk")
    {
        Remove-Item -LiteralPath "$env:USERPROFILE\Desktop\Chromium.lnk" -Force | Out-Null
    }
}

function downloadChromium
{
    if (-not(Test-Path -Path $zipFile)) {
        try
        {
            $null = Write-Progress "Downloading the latest Chromium win64 build..."
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri https://download-chromium.appspot.com/dl/Win_x64?type=snapshots -OutFile $env:TEMP\$zipFile -UseBasicParsing -ErrorAction Stop | Out-Null
            if (Test-Path -Path $env:TEMP\$zipFile -PathType Leaf)
            {
                Write-Host "$programName was downloaded successfully to $env:TEMP\$zipFile"
            }
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
}

function installChromium
{
    if (-not(Test-Path -Path "$installDir"))
    {
        Write-Progress "Extracting $programName to $installDir..."
        unzipFile "$env:TEMP\$zipFile" "$installDir"
        $ShortcutPath = "$env:USERPROFILE\Desktop\Chromium.lnk"
        $WSScriptObj = New-Object -ComObject ("WScript.Shell")
        $Shortcut = $WSScriptObj.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath =  "$installDir\chrome-win\chrome.exe"
        $Shortcut.Save()
        Write-Host "$programName has been installed at $installDir"
        Write-Information "A shortcut of Chromium has been created at $env:USERPROFILE\Desktop"
    }
    else
    {
        Write-Error "$programName is already installed in the directory $installDir"
    }
}

deleteChromium
downloadChromium
installChromium
