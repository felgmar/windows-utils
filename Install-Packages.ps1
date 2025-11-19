[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [String]$Package
)

process {
    $Principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $IsAdministrator = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($IsAdministrator) {
        Write-Error -Message "Do not run this script as a privileged user." -ErrorAction Stop
        return
    }

    $PackagesList = @{
        "9PJSDV0VPK04"                         = "Bitwarden"
        "XP89DCGQ3K6VLD"                       = "PowerToys"
        "XP9KHM4BK9FZ7Q"                       = "Visual Studio Code"
        "9MZ1SNWT0N5D"                         = "PowerShell"
        "9NN77TCQ1NC8"                         = "Mp3tag"
        "9PKTQ5699M62"                         = "iCloud"
        "9NP83LWLPZ9K"                         = "Apple Devices"
        "9PFHDD62MXS1"                         = "Apple Music"
        "XP8K4RGX25G3GM"                       = "CrystalDiskInfo"
        "XPDCFJDKLZJLP8"                       = "Visual Studio"
        "GitHub.GitHubDesktop"                 = "GitHub Desktop"
        "Git.Git"                              = "Git"
        "Guru3D.RTSS"                          = "RivaTuner Statistics Server"
        "JRSoftware.InnoSetup"                 = "Inno Setup"
        "PPSSPPTeam.PPSSPP"                    = "PPSSPP"
        "Valve.Steam"                          = "Steam"
        "7zip.7zip"                            = "7-Zip"
        "RevoUninstaller.RevoUninstaller"      = "Revo Uninstaller"
        "voidtools.Everything.Lite"            = "Everything Lite"
        "Neovim.Neovim"                        = "Neovim"
        "ShareX.ShareX"                        = "ShareX"
        "Corsair.iCUE.5"                       = "iCUE"
        "Intel.IntelDriverAndSupportAssistant" = "Intel Driver & Support Assistant"
        "Stenzek.DuckStation"                  = "DuckStation"
        "PCSX2Team.PCSX2"                      = "PCSX2"
        "Guru3D.Afterburner"                   = "MSI Afterburner"
        "Google.GoogleDrive"                   = "Google Drive"
        "Microsoft.WindowsTerminal"            = "Windows Terminal"
    }

    if (-not($Package)) {
        $PackagesList.Keys | ForEach-Object {
            $packageId = $_
            $packageName = $PackagesList[$packageId]
            Write-Host "Installing package: $packageName"
            Start-Process -FilePath "winget.exe" -ArgumentList (
                "install",
                "--exact",
                "--id $packageId",
                "--accept-source-agreements",
                "--accept-package-agreements",
                "--silent"
            ) -NoNewWindow -Wait
        }
    }
    else {
        Write-Host "Installing package: $Package"
        Start-Process -FilePath "winget.exe" -ArgumentList (
            "install",
            "--exact",
            "--id $packageId",
            "--accept-source-agreements",
            "--accept-package-agreements",
            "--silent"
        ) -NoNewWindow -Wait
    }
}
