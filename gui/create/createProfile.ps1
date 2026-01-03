# Load Helper Scripts
. "$PSScriptRoot\getAppsDetails.ps1"
. "$PSScriptRoot\getAppIcon.ps1"
. "$PSScriptRoot\convertIconToImage.ps1"

function Show-CreateGui {
    param (
        [string]$defaultProfileName = ""
    )
    Add-Type -AssemblyName PresentationFramework

    # Load XAML
    $xamlPath = Join-Path $PSScriptRoot "createProfile.xaml"
    $reader = [System.Xml.XmlReader]::Create($xamlPath)
    try {
        $window = [System.Windows.Markup.XamlReader]::Load($reader)
    }
    catch {
        Write-Error "Failed to load XAML: $_"
        return
    }

    # Find Controls
    $txtProfileName = $window.FindName("txtProfileName")
    if ($defaultProfileName) { $txtProfileName.Text = $defaultProfileName }
    $btnAddArg = $window.FindName("btnAddArg")
    $pnlArguments = $window.FindName("pnlArguments")
    $btnCreate = $window.FindName("btnCreate")
    $btnCancel = $window.FindName("btnCancel")
    $lstApps = $window.FindName("lstApps")
    $txtSearchApps = $window.FindName("txtSearchApps")

    # Load Apps
    $installedApps = Get-InstalledAppsDetails
    $appViewModels = [System.Collections.Generic.List[PSObject]]::new()

    foreach ($app in $installedApps) {
        $icon = $null
        if ($app.ExePath) {
            $icon = Get-AppIcon -exe $app.ExePath
        }
        
        if ($null -eq $icon) {
            $icon = [System.Drawing.SystemIcons]::Application
        }

        $imageSource = Convert-IconToImageSource -Icon $icon
        
        $viewModel = [PSCustomObject]@{
            Name       = $app.Name
            ExePath    = $app.ExePath
            Icon       = $imageSource
            IsSelected = $false
        }
        $appViewModels.Add($viewModel)
    }

    # Function to refresh list
    function Update-AppList {
        param($filter)
        $lstApps.ItemsSource = $null
        if ([string]::IsNullOrWhiteSpace($filter)) {
            $lstApps.ItemsSource = $appViewModels
        }
        else {
            $lstApps.ItemsSource = $appViewModels | Where-Object { $_.Name -match $filter }
        }
    }

    # Initial load
    Update-AppList

    # Search Event
    $txtSearchApps.Add_TextChanged({
            Update-AppList -filter $txtSearchApps.Text
        })

    # Add Argument Logic
    $btnAddArg.Add_Click({
            $rowPanel = New-Object System.Windows.Controls.Grid
            $rowPanel.Margin = "0,0,0,5"
        
            $col1 = New-Object System.Windows.Controls.ColumnDefinition
            $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
            $col2 = New-Object System.Windows.Controls.ColumnDefinition
            $col2.Width = [System.Windows.GridLength]::Auto
        
            $rowPanel.ColumnDefinitions.Add($col1)
            $rowPanel.ColumnDefinitions.Add($col2)

            # Argument Name Input
            $argInput = New-Object System.Windows.Controls.TextBox
            $argInput.Padding = "5"
            $argInput.Tag = "ArgName" # Tag used to retrieve value later
            # Placeholder text logic could be added here, but keeping it simple
        
            # Remove Button
            $removeBtn = New-Object System.Windows.Controls.Button
            $removeBtn.Content = "-"
            $removeBtn.Width = 25
            $removeBtn.Height = 25
            $removeBtn.Margin = "5,0,0,0"
            [System.Windows.Controls.Grid]::SetColumn($removeBtn, 1)
        
            $removeBtn.Add_Click({
                    $grid = $this.Parent
                    $stackPanel = $grid.Parent
                    $stackPanel.Children.Remove($grid)
                })

            $rowPanel.Children.Add($argInput)
            $rowPanel.Children.Add($removeBtn)

            $pnlArguments.Children.Add($rowPanel)
        
            # Focus the new input
            $argInput.Focus()
        })

    # Cancel Logic
    $btnCancel.Add_Click({
            $window.Close()
        })

    # Create Logic (Placeholder for now)
    $btnCreate.Add_Click({
            # Logic to gather data would go here
            $selectedApps = $appViewModels | Where-Object { $_.IsSelected }
            # You can access $selectedApps here to see what the user picked
            
            $window.DialogResult = $true
            $window.Close()
        })

    # Show Window
    $window.ShowDialog() | Out-Null
}
