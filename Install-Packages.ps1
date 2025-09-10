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
        "9PJSDV0VPK04"                          = "Bitwarden"
        "XP8C9QZMS2PC1T"                        = "Brave"
        "XP89DCGQ3K6VLD"                        = "PowerToys"
        "9NCBCSZSJRSB"                          = "Spotify"
        "XP9KHM4BK9FZ7Q"                        = "Visual Studio Code"
        "9MZ1SNWT0N5D"                          = "PowerShell"
        "9NN77TCQ1NC8"                          = "Mp3tag"
        "GitHub.GitHubDesktop"                  = "GitHub Desktop"
        "GitHub.cli"                            = "GitHub CLI"
        "Git.Git"                               = "Git"
        "Guru3D.RTSS"                           = "RivaTuner Statistics Server"
        "JRSoftware.InnoSetup"                  = "Inno Setup"
        "PPSSPPTeam.PPSSPP"                     = "PPSSPP"
        "Valve.Steam"                           = "Steam"
        "Microsoft.VisualStudio.2022.Community" = "Visual Studio 2022"
        "7zip.7zip"                             = "7-Zip"
        "ElectronicArts.EADesktop"              = "EA app"
        "RevoUninstaller.RevoUninstaller"       = "Revo Uninstaller"
        "voidtools.Everything.Lite"             = "Everything Lite"
        "Nextcloud.NextcloudDesktop"            = "Nextcloud"
        "Neovim.Neovim"                         = "Neovim"
        "ShareX.ShareX"                         = "ShareX"
        "Corsair.iCUE.5"                        = "iCUE"
        "Intel.IntelDriverAndSupportAssistant"  = "Intel Driver & Support Assistant"
        "XP8K4RGX25G3GM"                        = "CrystalDiskInfo"
        "Stenzek.DuckStation"                   = "DuckStation"
        "PCSX2Team.PCSX2"                       = "PCSX2"
        "Guru3D.Afterburner"                    = "MSI Afterburner"
        "Google Drive"                          = "Google.GoogleDrive"
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
