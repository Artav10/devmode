[CmdletBinding(DefaultParameterSetName = 'Run')]
param (
  # Mode name (common to all cases)
  [Parameter(
    Mandatory = $true,
    Position = 0
  )]
  [string]$profileName,

  # -------- Actions --------
  [Parameter(ParameterSetName = 'Create')]
  [Alias('c')]
  [switch]$Create,

  [Parameter(ParameterSetName = 'Edit')]
  [Alias('e')]
  [switch]$Edit,

  [Parameter(ParameterSetName = 'Delete')]
  [Alias('d')]
  [switch]$Delete,

  # -------- Mode arguments --------
  [Parameter(
    ValueFromRemainingArguments = $true,
    ParameterSetName = 'Run'
  )]
  [string[]]$argsFromProfile
)

#imports
. "$PSScriptRoot\gui\editMenu.ps1"
. "$PSScriptRoot\gui\createProfile.ps1"
. "$PSScriptRoot\lib\launch\git.ps1"
. "$PSScriptRoot\lib\launch\apps.ps1"
. "$PSScriptRoot\lib\launch\custom_commands.ps1"


function Invoke-GenericLaunch {
  #Replace args in profile file
  $jsonContent = Get-Content "$PSScriptRoot\profiles.json" -Raw
  . "$PSScriptRoot\lib\utils\parse_file_with_arg.ps1"
  $jsonContent = Update-ArgsInString -jsonContent $jsonContent -argsFromProfile $argsFromProfile

  $config = $jsonContent | ConvertFrom-Json


  #Validate profile
  $currentProfile = $config.$profileName
  if (-not $currentProfile) {
    Write-Error "Unknown profile: $profileName"
    exit 1
  }
  $nbArgs = $currentProfile.nbArgs
  if ($argsFromProfile.Count -lt $nbArgs) {
    Write-Error "Insufficient argsFromProfile for profile $profileName. Expected: $nbArgs, Received: $($argsFromProfile.Count)"
    exit 1
  }

  #git
  if ($currentProfile.git) {
    Invoke-GitCommands -details $currentProfile.git.details -VerboseMode:$VerboseMode
  }

  #Launch apps
  if ( $currentProfile.apps ) {
    Start-Apps -apps $currentProfile.apps -VerboseMode:$VerboseMode
  }

  #Custom commands
  if ( $currentProfile.customCommands ) {
    Invoke-CustomCommands -commands $currentProfile.customCommands -VerboseMode:$VerboseMode
  }

  exit 0
}

# Invoke-GenericLaunch 

switch ($PSCmdlet.ParameterSetName) {
  'Run' {
    Write-Host "Launching mode '$profileName'"
    Write-Host "Arguments : $argsFromProfile"
    Invoke-GenericLaunch 
  }

  'Create' {
    Write-Host "Creating profile '$profileName'"
    Show-CreateGui
  }

  'Edit' {
    Write-Host "Editing profile '$profileName'"
    Show-EditGui
  }

  'Delete' {
    Write-Host "Deleting profile '$profileName'"
  }
  Default {
    Write-Error "Unknown parameter set: $($PSCmdlet.ParameterSetName)"
    exit 1
  }
}
