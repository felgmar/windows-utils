[CmdletBinding()]
param (
   [Parameter(Mandatory = $true)]
   [String]$SourceFile,

   [Parameter(Mandatory = $true)]
   [String]$DestinationPath
)

process {
    Expand-Archive -LiteralPath $SourceFile -DestinationPath $DestinationPath | Out-Null
}
