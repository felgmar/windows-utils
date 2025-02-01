[CmdletBinding()]
param (
   [Parameter(Mandatory = $true)]
   [String]$Name,

   [Parameter(Mandatory = $true)]
   [String]$Email,

   [Parameter(Mandatory = $true)]
   [String]$SigningKey,

   [Parameter(Mandatory = $true)]
   [ValidateSet('ssh')]
   [String]$GPGFormat,

   [Parameter(Mandatory = $false)]
   [Bool]$ReplaceAll
)

process {
    if ($ReplaceAll)
    {
        Start-Process -FilePath "git" -ArgumentList ('config', '--global', 'user.name', "$Name", '--replace-all') -LoadUserProfile -NoNewWindow -Wait
        Start-Process -FilePath "git" -ArgumentList ('config', '--global', 'user.email', "$Email", '--replace-all') -LoadUserProfile -NoNewWindow -Wait
        Start-Process -FilePath "git" -ArgumentList ('config', '--global', 'gpg.format', "$GPGFormat", '--replace-all') -LoadUserProfile -NoNewWindow  -Wait
    } else {
        Start-Process -FilePath "git" -ArgumentList ('config', '--global', 'user.name', "$Name") -LoadUserProfile -NoNewWindow -Wait
        Start-Process -FilePath "git" -ArgumentList ('config', '--global', 'user.email', "$Email") -LoadUserProfile -NoNewWindow -Wait
        Start-Process -FilePath "git" -ArgumentList ('config', '--global', 'gpg.format', "$GPGFormat") -LoadUserProfile -NoNewWindow  -Wait
    }

    if (Test-Path $SigningKey) {
        Start-Process -FilePath "git" -ArgumentList ('config', '--global', 'user.signingkey', "$SigningKey") -LoadUserProfile -NoNewWindow -Wait
        Start-Process -FilePath "ssh-add" -ArgumentList ("$SigningKey") -LoadUserProfile -NoNewWindow -Wait
    } else {
        Start-Process -FilePath "ssh-add" -LoadUserProfile -NoNewWindow -Wait
    }
}
