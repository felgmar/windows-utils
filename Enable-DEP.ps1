#requires -RunAsAdministrator

process {
    $BCDEntries = (bcdedit /enum | Select-String -Pattern 'nx') | ForEach-Object {
        $_.ToString().Trim() -replace ('nx\s+(\w+)', '$1')
    }

    try {
        $BCDEntries | ForEach-Object {
            if ($_ -eq 'OptOut') {
                throw "Data Execution Prevention (DEP) is already set to $_."
            }

            $PreviousState = "$_"
            Write-Host "Changing Data Execution Prevention (DEP) from ${PreviousState} to OptOut..." -ForegroundColor Yellow
            Start-Process -FilePath "bcdedit.exe" -ArgumentList ('/set', '{current}', 'nx', "OptOut") -NoNewWindow -Wait -PassThru

            if ($LASTEXITCODE -ne 0) {
                throw "Failed to enable Data Execution Prevention (DEP). Exit code: ${LASTEXITCODE}"
            }

            Write-Host "Data Execution Prevention (DEP) has been successfully enabled." -ForegroundColor Green
        }
    }
    catch {
        throw $_.Exception.Message
    }
}
