[CmdletBinding()]
param (
   [Parameter(Mandatory = $false)]
   [String]$Package
)

process {
    $PackagesList = @{
        "9PJSDV0VPK04" = "Bitwarden"
        "XP89DCGQ3K6VLD" = "PowerToys"
        "9NCBCSZSJRSB" = "Spotify"
        "XP9KHM4BK9FZ7Q" = "Visual Studio Code"
        "9MZ1SNWT0N5D" = "PowerShell"
        "GitHub.GitHubDesktop" = "GitHub Desktop"
        "GitHub.cli" = "GitHub CLI"
        "Git.Git" = "Git"
        "JRSoftware.InnoSetup" = "Inno Setup"
        "PPSSPPTeam.PPSSPP" = "PPSSPP"
        "Valve.Steam" = "Steam"
        "Microsoft.VisualStudio.2022.Community" = "Visual Studio 2022"
        "7zip.7zip" = "7-Zip"
        "ElectronicArts.EADesktop" = "EA app"
        "RevoUninstaller.RevoUninstaller" = "Revo Uninstaller"
        "voidtools.Everything.Lite" = "Everything Lite"
        "Nextcloud.NextcloudDesktop" = "Nextcloud"
        "Neovim.Neovim" = "Neovim"
        "ShareX.ShareX" = "ShareX"
        "Corsair.iCUE.5" = "iCUE"
        "Intel.IntelDriverAndSupportAssistant" = "Intel Driver & Support Assistant"
    }

    if (-not($Package))
    {
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
    } else {
        Write-Host "Installing package: $Package"
        Start-Process -FilePath "winget.exe" -ArgumentList ("install", "--exact", "--id", $Package) -NoNewWindow -Wait
    }
}
