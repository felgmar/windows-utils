[CmdletBinding()]
param (
   [Parameter(Mandatory = $false)]
   [String]$DestinationPath
)

process {
    [String]$url = 'https://www.uwe-sieber.de/files'
    [Array]$filenames = @('DriveCleanup.zip', 'DeviceCleanupCmd.zip')

    try {
        $filenames.ForEach({
            [String]$file = "$url/$_"
            [String]$file_no_extension = $_.Replace(".zip", "")
            
            if (Test-Path -LiteralPath "$env:SystemDrive\$file_no_extension.exe") {
                Write-Error -Message "The file $file_no_extension.exe already exists in $env:SystemDrive\."
            } else {
                Write-Host "Downloading file $file..."
                Invoke-WebRequest -Uri "$file" -OutFile "$env:SystemDrive\$_" -ErrorAction Stop

                Write-Host "Extracting file $_... to $env:SystemDrive\"
                Expand-Archive -Path "$env:SystemDrive\$_" -DestinationPath "$env:SystemDrive\"

                if (Test-Path -LiteralPath "$env:SystemDrive\Win32") {
                    Remove-Item -LiteralPath "$env:SystemDrive\Win32" -Recurse -Force
                }

                if (Test-Path -LiteralPath "$env:SystemDrive\x64\$file_no_extension.exe") {
                    Move-Item -LiteralPath "$env:SystemDrive\x64\$file_no_extension.exe" -Destination "$env:SystemDrive\"
                    Remove-Item -LiteralPath "$env:SystemDrive\x64" -Recurse -Force
                }

                if (Test-Path -LiteralPath "$env:SystemDrive\$file_no_extension.txt") {
                    Remove-Item -LiteralPath "$env:SystemDrive\$file_no_extension.txt" -Force
                }

                Write-Host "Removing file $_..."
                Remove-Item -Path "$env:SystemDrive\$_"
            }
        })
    }
    catch {
        Write-Error -Message $_.Exception.Message -Exception $_.Exception -Category $_.CategoryInfo.Category
    }
}
