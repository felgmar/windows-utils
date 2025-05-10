function Get-LatestRelease() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String]$User,
        
        [Parameter(Mandatory=$true)]
        [String]$Repository,

        [Parameter(Mandatory=$false)]
        [String]$DestinationPath,

        [Parameter(Mandatory=$true)]
        [String]$Platform,

        [Parameter(Mandatory=$false)]
        [Switch]$Authenticated
    )
    process {
        if (-not $DestinationPath) {
            $DestinationPath = Join-Path -Path $env:USERPROFILE -ChildPath "Downloads"
        }

        if ($Authenticated) {
            [String]$Command = "gh api --method GET /repos/$User/$Repository/releases/latest"
            [PSCustomObject]$ReleaseInfo = Invoke-Expression -Command $Command | ConvertFrom-Json
        } else {
            [String]$URL = "https://api.github.com/repos/$User/$Repository/releases/latest"
            [String]$Command = Invoke-WebRequest -Uri $URL -UserAgent 'Mozilla/5.0'
            [String]$ReleaseInfo = $Command | ConvertFrom-Json
        }

        [Array]$Assets = $ReleaseInfo.assets
        foreach ($Asset in $Assets) {
            [String]$DownloadUrl = $Asset.browser_download_url
            [String]$FileName = Split-Path -Path $DownloadUrl -Leaf
            [String]$FileExtension = [System.IO.Path]::GetExtension($FileName)
            [String]$FilePath = Join-Path -Path $DestinationPath -ChildPath $FileName
            try {
                switch ($Platform) {
                    'linux' {
                        if ($FileExtension -eq '.AppImage' -or $FileExtension -eq '.flatpak' -and $FileName.Contains('linux'))
                        {
                            if (-not(Test-Path -LiteralPath "$FilePath")) {
                                Write-Host "Downloading $FileName to $FilePath..."
                                Invoke-WebRequest -Uri $DownloadUrl -OutFile $FilePath
                            } else {
                                Write-Warning -Message "File $FilePath already exists."
                            }
                        }
                    }
                    'windows' {
                        if ($FileExtension -eq '.exe' -or $FileExtension -eq '.zip' -and $FileName.Contains('windows') -or $FileName.Contains('win'))
                        {
                            if (-not(Test-Path -LiteralPath $FilePath)) {
                            Write-Host "Downloading $FileName to $FilePath..."
                            Invoke-WebRequest -Uri $DownloadUrl -OutFile $FilePath
                            } else {
                                Write-Warning -Message "File $FilePath already exists."
                            }
                        }
                    }
                    'mac' {
                        throw "Not implemented."
                    }
                    Default {
                        throw "Unknown platform: $Platform"
                    }
                }
            }
            catch {
                throw;
            }
        }
    }
}

$Platforms = @('windows', 'linux')
$Repositories = @(
    @{ User = 'PCSX2'; Repo = 'pcsx2' },
    @{ User = 'stenzek'; Repo = 'duckstation' },
    @{ User = 'RPCS3'; Repo = 'rpcs3-binaries-win' },
    @{ User = 'RPCS3'; Repo = 'rpcs3-binaries-linux' }
)

foreach ($Platform in $Platforms) {
    foreach ($Repository in $Repositories) {
        Get-LatestRelease -DestinationPath "$env:USERPROFILE\Downloads" `
                          -User $Repository.User `
                          -Repository $Repository.Repo `
                          -Authenticated `
                          -Platform $Platform
    }
}
