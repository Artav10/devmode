function Get-InstalledAppsDetails {

    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $apps = foreach ($path in $paths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        Select-Object @{
            Name       = "Name"
            Expression = { $_.DisplayName }
        }, @{
            Name       = "ExePath"
            Expression = {
                if ($_.DisplayIcon) {
                    $path = ($_.DisplayIcon -replace ',\d+$').Trim('"')
                    [System.Environment]::ExpandEnvironmentVariables($path)
                }
            }
        }
    }

    return $apps | Sort-Object Name -Unique

}