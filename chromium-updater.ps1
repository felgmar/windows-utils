#
# Created by Liam Powell (gfelipe099)
# Chromium updater tool
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
                Write-Error "This script needs Administrator privileges to work, try again."
                Start-Sleep 5
                Exit
        }
    }
}

$programName = 'Chromium'
$zipFile = 'chrome-win.zip'
$installDir = "$env:ProgramFiles/The Chromium Project/Chromium"

function unzipFile {
    #
    # Function source:
    # 'https://stackoverflow.com/questions/27768303/how-to-unzip-a-file-in-powershell'
    #
    param([string]$zipFile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $outpath)
}

if (-not(Test-Path -Path $zipFile -PathType Leaf)) {
    try {
        $null = Write-Progress "Downloading the latest Chromium win64 build..."
        Invoke-WebRequest -Uri https://download-chromium.appspot.com/dl/Win_x64?type=snapshots -OutFile $env:TEMP/$zipFile -UseBasicParsing -ErrorAction Stop | Out-Null
        if (Test-Path -Path $env:TEMP/$zipFile -PathType Leaf) {
            Write-Host "'$programName' was downloaded successfully"
            Write-Host ""
            Write-Progress "Extracting '$programName' to '$installDir'..."
            unzipFile "$env:TEMP/$zipFile" "$installDir"
            if (Test-Path -Path "$installDir" -PathType Leaf) {
                Write-Host "'$programName' was installed correctly at '$installDir'"
            } else {
                Write-Error "'$programName' is already installed in the directory '$installDir' "
            }
        }
    }
    catch {
        throw $_.Exception.Message
    }
} else {
    Write-Error "File '$zipFile' already exists, delete it and try again..."
}
