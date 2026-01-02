function Invoke-CustomCommands {
    param (
        [array]$commands,
        [switch]$VerboseMode
    )

    foreach ($entry in $commands) {
        $cmd = $entry.command
        $loc = $entry.location

        if ([string]::IsNullOrWhiteSpace($cmd)) {
            continue
        }

        if ($VerboseMode) {
            $msg = "Executing custom command: $cmd"
            if ($loc) { $msg += " in $loc" }
            Write-Host $msg
        }

        if (-not [string]::IsNullOrWhiteSpace($loc)) {
            if (Test-Path $loc) {
                Push-Location $loc
                try {
                    Invoke-Expression $cmd
                }
                finally {
                    Pop-Location
                }
            }
            else {
                Write-Warning "Location not found: $loc. Command '$cmd' skipped."
            }
        }
        else {
            Invoke-Expression $cmd
        }
    }
}