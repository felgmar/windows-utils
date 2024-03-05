[CmdletBinding()]
param (
   [Parameter(Mandatory = $false)]
   [String]$Package
)

process {
    if (-not($Package))
    {
        $UWPPackages = @(
            "9MZ1SNWT0N5D",    # PowerShell
            "9NCVDN91XZQP",    # Python 3.12
            "9NCBCSZSJRSB",    # Spotify
            "9NKSQGP7F2NH",    # WhatsApp
            "XP89DCGQ3K6VLD",  # PowerToys
            "9NBLGGH0L44H"     # Wallhaven.cc
        )

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
            "GnuPG.Gpg4win",
            "voidtools.Everything.Lite"
        )

        foreach ($package in $UWPPackages) {
            Write-Host "Installing package: $package"
            Start-Process -FilePath "winget.exe" -ArgumentList ("install", "--exact", "--id", $package) -NoNewWindow -Wait
        }

        foreach ($package in $PackagesList) {
            Write-Host "Installing package: $package"
            Start-Process -FilePath "winget.exe" -ArgumentList ("install", "--exact", "--id", $package) -NoNewWindow -Wait
        }
    }
}
