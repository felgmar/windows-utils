[CmdletBinding()]
param (
   [Parameter(Mandatory = $true)]
   [String] $ProgramName,

   [Parameter(Mandatory = $true)]
   [String] $ShortcutPath,

   [Parameter(Mandatory = $false)]
   [String] $TargetPath
)

process {
    $Shell = New-Object -ComObject ("WScript.Shell")
    $Shortcut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\$ProgramName.lnk")
    $Shortcut.TargetPath = $TargetPath
    #$Shortcut.WorkingDirectory = $TargetPath.Trim("\$ProgramName.exe")
    $Shortcut.IconLocation = "$TargetPath, 0"
    $Shortcut.Save()
}