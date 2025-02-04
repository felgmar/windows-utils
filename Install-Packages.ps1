[CmdletBinding()]
param (
   [Parameter(Mandatory = $false)]
   [String]$Package
)

process {
    if (-not($Package))
    {
        $PackagesList = @(
            "9PJSDV0VPK04", # Bitwarden
            "XP89DCGQ3K6VLD", # PowerToys
            "9NCBCSZSJRSB", # Spotify
            "XP9KHM4BK9FZ7Q" # VS Code
            "9MZ1SNWT0N5D", # PowerShell
            "GitHub.GitHubDesktop",
            "GitHub.cli",
            "Git.Git",
            "JRSoftware.InnoSetup",
            "PPSSPPTeam.PPSSPP"
            "Valve.Steam",
            "Microsoft.VisualStudio.2022.Community",
            "7zip.7zip",
            "Telegram.TelegramDesktop",
            "ElectronicArts.EADesktop",
            "RevoUninstaller.RevoUninstaller",
            "voidtools.Everything.Lite",
            "Nextcloud.NextcloudDesktop",
            "Neovim.Neovim",
            "ShareX.ShareX",
            "Corsair.iCUE.5",
            "Intel.IntelDriverAndSupportAssistant",
            "ONLYOFFICE.DesktopEditors"
        )

        foreach ($package in $PackagesList) {
            Write-Host "Installing package: $package"
            Start-Process -FilePath "winget.exe" -ArgumentList ("install", "--exact", "--id", $package) -NoNewWindow -Wait
        }
    } else {
        Write-Host "Installing package: $Package"
        Start-Process -FilePath "winget.exe" -ArgumentList ("install", "--exact", "--id", $Package) -NoNewWindow -Wait
    }
}
