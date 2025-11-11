[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [String]$URL,
    [Parameter(Mandatory = $true)]
    [String]$OutputPath,
    [Parameter(Mandatory = $true)]
    [String]$FileName
)

begin {
    [Boolean]$IsURLEmpty = [string]::IsNullOrWhiteSpace($URL)
    [Boolean]$IsOutputPathEmpty = [string]::IsNullOrWhiteSpace($OutputPath)
    [String]$OutFile = Join-Path -Path "$OutputPath" -ChildPath "$FileName"

    if ($IsURLEmpty) {
        throw "No URL"
    }

    if ($IsOutputPathEmpty) {
        throw "No output path"
    }

    if (Test-Path -Path "$OutputPath") {
        Write-Warning "$OutputPath already exists."
    }
}

process {
    New-Item -Path "$OutputPath" -ItemType "Directory"
    New-Item -Path "$OutputPath" -ItemType "Directory"

    if (Test-Path -LiteralPath "$OutFile") {
        Write-Warning "File $OutFile already exists."
    }
    try {
        Start-BitsTransfer -Source $URL -Destination $OutFile -DisplayName "Downloading $FileName..."
        Invoke-WebRequest -Uri $URL -OutFile $OutFile
    }
    catch {
        throw $_.Exception.Message
    }
}
