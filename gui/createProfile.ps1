function Show-CreateGui {
    Add-Type -AssemblyName PresentationFramework

    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Create Profile" Height="450" Width="350" WindowStartupLocation="CenterScreen">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Profile Name Section -->
        <StackPanel Grid.Row="0" Margin="0,0,0,15">
            <Label Content="Profile Name" FontWeight="Bold"/>
            <TextBox Name="txtProfileName" Padding="5"/>
        </StackPanel>

        <!-- Arguments Header -->
        <Grid Grid.Row="1" Margin="0,0,0,5">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <Label Content="Arguments (Optional)" FontWeight="Bold"/>
            <Button Name="btnAddArg" Content="+" Width="25" Height="25" Grid.Column="1" 
                    ToolTip="Add new argument"/>
        </Grid>

        <!-- Arguments List -->
        <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" Margin="0,0,0,10">
            <StackPanel Name="pnlArguments">
                <!-- Dynamic arguments will be added here -->
            </StackPanel>
        </ScrollViewer>

        <!-- Footer Actions -->
        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right">
            <Button Name="btnCancel" Content="Cancel" Width="80" Height="25" Margin="0,0,10,0"/>
            <Button Name="btnCreate" Content="Create" Width="80" Height="25"/>
        </StackPanel>
    </Grid>
</Window>
"@

    # Parse XAML
    $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
    try {
        $window = [System.Windows.Markup.XamlReader]::Load($reader)
    } catch {
        Write-Error "Failed to load XAML: $_"
        return
    }

    # Find Controls
    $txtProfileName = $window.FindName("txtProfileName")
    $btnAddArg = $window.FindName("btnAddArg")
    $pnlArguments = $window.FindName("pnlArguments")
    $btnCreate = $window.FindName("btnCreate")
    $btnCancel = $window.FindName("btnCancel")

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
        $window.DialogResult = $true
        $window.Close()
    })

    # Show Window
    $window.ShowDialog() | Out-Null
}
