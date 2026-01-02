function Start-Apps {
    param (
        $apps,
        [switch]$VerboseMode
    )
    
    foreach ($app in $apps.PSObject.Properties.Name) {
        $appConfig = $apps.$app
        switch ($app) {
            "code" {
                foreach ($details in $appConfig.details) {
                    if ( -not (Test-Path $details.path)) {
                        Write-Warning "Folder not found for VS Code: $($details.path)"
                        continue
                    }
                    if ($details.withCommandInTerminal) {
                        . "$PSScriptRoot\..\utils\create_vsc_task.ps1"
                        foreach ($cmd in $details.withCommandInTerminal) {
                            New-VSCTask -projectPath $details.path -VerboseMode:$VerboseMode -commandWithArgs $cmd
                        }
                    }
                    code $details.path
                    if ( $VerboseMode ) {
                        Write-Host "Launching VS Code with folder: $($details.path)"
                    }
                }
            }

            { $_ -in "firefox", "chrome" } {
                if ($appConfig.urls) {
                    Start-Process $_ ($appConfig.urls -join " ")
                    if ( $VerboseMode ) {
                        Write-Host "Launching $app with URLs: $($appConfig.urls -join ", ")"
                    }
                }
            }
            default {
                if ($appConfig -is [string] -or $appConfig -is [array]) {
                    Start-Process "${app}://" ($appConfig -join " ")
                    if ( $VerboseMode ) {
                        Write-Host "Launching $app with arguments: $($appConfig -join ", ")"
                    }
                }
                else {
                    Start-Process "${app}://"
                    if ( $VerboseMode ) {
                        Write-Host "Launching $app without arguments"
                    }
                }
            }
        }
    }
}
