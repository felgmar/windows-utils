[CmdletBinding()]
param (
   [Parameter(Mandatory = $false)]
   [String]$Package
)

process {
    if (-not($Package))
    {
        $PackagesList = @(
            "Bitwarden.Bitwarden", # Bitwarden
            "GitHub.GitHubDesktop",
            "GitHub.cli",
            "Git.Git",
            "JRSoftware.InnoSetup",
            "PPSSPPTeam.PPSSPP"
            "Valve.Steam",
            "Microsoft.VisualStudio.2022.Community",
            "7zip.7zip",
            "Telegram.TelegramDesktop",
            "XP9KHM4BK9FZ7Q", # Visual Studio Code
            "ElectronicArts.EADesktop",
            "Klocman.BulkCrapUninstaller",
            "voidtools.Everything.Lite",
            "Nextcloud.NextcloudDesktop",
            "Mozilla.Firefox",
            "9NCBCSZSJRSB", # Spotify
            "PPSSPPTeam.PPSSPP",
            "Neovim.Neovim",
            "ShareX.ShareX",
            "Telegram.TelegramDesktop",
            "Microsoft.PowerToys",
            "Ryochan7.DS4Windows",
            "Corsair.iCUE.5",
            "Intel.IntelDriverAndSupportAssistant"
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
