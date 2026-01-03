function Show-EditGui {

    Add-Type -AssemblyName PresentationFramework

    [xml]$xaml = @"
<Window
  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Devmode – Éditeur de mode"
  Height="300"
  Width="400"
  WindowStartupLocation="CenterScreen"
  ResizeMode="NoResize">

  <Grid Margin="10">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
    </Grid.RowDefinitions>

    <!-- Titre -->
    <TextBlock
      Text="Création / édition d’un mode"
      FontSize="18"
      FontWeight="Bold"
      Margin="0,0,0,15"/>

    <!-- Type -->
    <StackPanel Grid.Row="1" Margin="0,0,0,10">
      <TextBlock Text="Type :" />
      <ComboBox Name="TypeBox" SelectedIndex="0">
        <ComboBoxItem Content="minecraft"/>
      </ComboBox>
    </StackPanel>

    <!-- Nom du pack -->
    <StackPanel Grid.Row="2" Margin="0,0,0,15">
      <TextBlock Text="Nom du pack :" />
      <TextBox Name="PackNameBox" />
    </StackPanel>

    <!-- Boutons -->
    <StackPanel
      Grid.Row="3"
      Orientation="Horizontal"
      HorizontalAlignment="Right">

      <Button Name="CancelBtn" Width="80" Margin="0,0,10,0">
        Annuler
      </Button>

      <Button Name="OkBtn" Width="80">
        OK
      </Button>
    </StackPanel>
  </Grid>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)

    # Récupération des contrôles
    $typeBox = $window.FindName("TypeBox")
    $packNameBox = $window.FindName("PackNameBox")
    $okBtn = $window.FindName("OkBtn")
    $cancelBtn = $window.FindName("CancelBtn")

    $result = $null

    $okBtn.Add_Click({
            if ([string]::IsNullOrWhiteSpace($packNameBox.Text)) {
                [System.Windows.MessageBox]::Show(
                    "Le nom du pack est obligatoire",
                    "Erreur",
                    "OK",
                    "Warning"
                ) | Out-Null
                return
            }

            $result = @{
                type     = $typeBox.Text
                packName = $packNameBox.Text
            }

            $window.Close()
        })

    $cancelBtn.Add_Click({
            $window.Close()
        })

    $window.ShowDialog() | Out-Null
    return $result
}
