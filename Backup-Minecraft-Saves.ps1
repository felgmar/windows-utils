param(
    [Parameter]
    [String]$DestinationPath,
    [Parameter]
    [String]$FileName
)

[String]$Date = Get-Date -Format "MM_dd_yyyy_hhmmss"
[String]$APPDATA = $env:APPDATA
[String]$MINECRAFT_DIR = Join-Path -Path "$APPDATA" -ChildPath ".minecraft"
[String]$MINECRAFT_SAVES_DIR = Join-Path -Path "$MINECRAFT_DIR" -ChildPath "saves"

foreach ($Item in Get-ChildItem -Path $MINECRAFT_SAVES_DIR -Directory) {
    [String]$ItemFullPath = Join-Path -Path $MINECRAFT_SAVES_DIR -ChildPath "$Item"
    if (-not($DestinationPath)) {
        [String]$DestinationPath = "$env:USERPROFILE\$ItemFileName"
    }

    if (-not($FileName)) {
        [String]$ItemFileName = "backup-$Item-$Date.zip"
    }

    try {
        Compress-Archive -Path $ItemFullPath -DestinationPath "$DestinationPath\$ItemFileName" -CompressionLevel Optimal -Update
    }
    catch {
        throw $_.Message
    }
}
