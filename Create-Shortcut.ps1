[CmdletBinding()]
param (
   [Parameter(Mandatory = $true)]
   [String]$ProgramName,

   [Parameter(Mandatory = $true)]
   [String]$ShortcutPath,

   [Parameter(Mandatory = $true)]
   [String]$TargetPath,

   [Parameter(Mandatory = $false)]
   [String]$WorkingDirectory
)

process {
    $Shell = New-Object -ComObject ("WScript.Shell")
    $Shortcut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\$ProgramName.lnk")
    $Shortcut.TargetPath = $TargetPath
    if (-not($WorkingDirectory))
    {
        $Shortcut.WorkingDirectory = $TargetPath.TrimEnd($ProgramName)
    }
    else
    {
        $Shortcut.WorkingDirectory = $WorkingDirectory
    }
    $Shortcut.IconLocation = "$TargetPath, 0"
    $Shortcut.Save()
}
