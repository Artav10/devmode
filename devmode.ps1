param (
  [Parameter(Mandatory)]
  [string]$profileName,

  [Alias('v')]
  [switch]$VerboseMode,

  [Parameter(ValueFromRemainingArguments)]
  [string[]]$argsFromProfile
)

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
  . "$PSScriptRoot\lib\launch\git.ps1"
  if ($currentProfile.git) {
    Invoke-GitCommands -details $currentProfile.git.details -VerboseMode:$VerboseMode
  }

  #Launch apps
  . "$PSScriptRoot\lib\launch\apps.ps1"
  if ( $currentProfile.apps ) {
    Start-Apps -apps $currentProfile.apps -VerboseMode:$VerboseMode
  }

  exit 0
}

Invoke-GenericLaunch 
