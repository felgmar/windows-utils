#requires -RunAsAdministrator

process {
    $BCDEntries = (bcdedit /enum | Select-String -Pattern 'hypervisorlaunchtype') | ForEach-Object {
        $_.ToString().Trim() -replace ('hypervisorlaunchtype\s+(\w+)', '$1')
    }

    try {
        $BCDEntries | ForEach-Object {
            if ($_ -eq 'off') {
                Write-Warning -Message "Hypervisor launch type is already set to $_."
                return
            }

            $PreviousState = $_
            Write-Host "Changing hypervisor launch type from $PreviousState to off..." -ForegroundColor Yellow
            Start-Process -FilePath "bcdedit.exe" -ArgumentList ('/set', '{current}', 'hypervisorlaunchtype', "off") -NoNewWindow -Wait -PassThru

            if ($LASTEXITCODE -ne 0) {
                throw "Failed to disable hypervisor launch type. Exit code: $LASTEXITCODE"
            }

            Write-Host "Hypervisor launch type has been successfully disabled." -ForegroundColor Green
            Write-Warning -Message "For the changes to take effect you must reboot your computer."
            $RebootComputer = Read-Host -Prompt "Do you want to reboot your computer now? <y/n>"
            if ($RebootComputer -match '^y(es)?$') {
                shutdown.exe /r /t 5
            }
        }
    } catch {
        throw $_.Exception.Message
    }
}
