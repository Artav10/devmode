Add-Type -AssemblyName System.Drawing

function Get-AppIcon {
    param ([string]$exe)

    if (-not (Test-Path $exe)) { return $null }

    try {
        return [System.Drawing.Icon]::ExtractAssociatedIcon($exe)
    }
    catch {
        return $null
    }
}
