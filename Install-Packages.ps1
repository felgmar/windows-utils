[CmdletBinding()]
param (
   [Parameter(Mandatory = $false)]
   [String]$Package
)

process {
    if (-not($Package))
    {
        $PackagesList = @(
            "Bitwarden.Bitwarden",
            "GitHub.GitHubDesktop",
            "GitHub.cli",
            "Git.Git",
            "JRSoftware.InnoSetup",
            "PPSSPPTeam.PPSSPP"
            "Valve.Steam",
            "Microsoft.VisualStudio.2022.Community",
            "7zip.7zip",
            "Telegram.TelegramDesktop",
            "Microsoft.VisualStudioCode",
            "ElectronicArts.EADesktop",
            "Klocman.BulkCrapUninstaller",
            "voidtools.Everything.Lite",
            "Spotify.Spotify"
            "PPSSPPTeam.PPSSPP",
            "Neovim.Neovim",
            "ShareX.ShareX",
            "Telegram.TelegramDesktop",
            "Microsoft.PowerToys"
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
