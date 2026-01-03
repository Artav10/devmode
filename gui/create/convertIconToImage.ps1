
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName System.Drawing

function Convert-IconToImageSource {
    param ([System.Drawing.Icon]$Icon)

    if ($null -eq $Icon) { return $null }

    try {
        $imageSource = [System.Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
            $Icon.Handle,
            [System.Windows.Int32Rect]::Empty,
            [System.Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
        )
        $imageSource.Freeze() # Make it cross-thread accessible if needed
        return $imageSource
    }
    catch {
        Write-Error "Failed to convert icon: $_"
        return $null
    }
}
