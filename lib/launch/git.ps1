function Invoke-GitCommands {
    param (
        [Parameter(Mandatory)]
        $details,
        [switch]$VerboseMode
    )

    foreach ($detail in $details) {
        Push-Location $detail.path

        foreach ($command in $detail.commands) {
            if ($VerboseMode) {
                Write-Host "Executing git $command in $($detail.path)"
            }
            git $command
        }

        Pop-Location
    }
}