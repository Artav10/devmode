function New-VSCTask {
  param (
    [string]$projectPath,
    [switch]$VerboseMode,
    [string]$commandWithArgs
  )

  $parts = $commandWithArgs -split ' '
  $command = $parts[0]
  $cmdArgs = @()
  if ($parts.Count -gt 1) {
    $cmdArgs = @($parts[1..($parts.Count - 1)])
  }


  $vscodeDir = Join-Path $projectPath ".vscode"
  $tasksFile = Join-Path $vscodeDir "tasks.json"
  
  # Ensure jsonArgs is a valid JSON array string (e.g. [], ["arg"], ["a","b"])
  $jsonArgs = "[]"
  if ($cmdArgs.Count -gt 0) {
    $jsonArgs = @($cmdArgs) | ConvertTo-Json -Compress
    if (-not $jsonArgs.StartsWith("[")) { $jsonArgs = "[$jsonArgs]" }
  }

  $taskLabel = "devmode-$command-auto"

  if (-Not (Test-Path $tasksFile)) {
    Write-Host "Creating tasks.json for $command in $vscodeDir"
    New-Item -ItemType Directory -Force -Path $vscodeDir | Out-Null
    @"
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "$taskLabel",
      "type": "shell",
      "command": "$command",
      "args": $jsonArgs,
      "isBackground": true,
      "presentation": {
        "panel": "dedicated",
        "reveal": "always"
      },
      "runOptions": {
        "runOn": "folderOpen"
      }
    }
  ]
}
"@ | Set-Content -Encoding UTF8 $tasksFile
  }
  else {
    Write-Host "Updating tasks.json for $command in $vscodeDir"
    $jsonContent = Get-Content -Raw -Path $tasksFile | ConvertFrom-Json
    
    # Ensure tasks array exists
    if (-not $jsonContent.tasks) {
      $jsonContent | Add-Member -MemberType NoteProperty -Name "tasks" -Value @()
    }

    
    $existingTask = $jsonContent.tasks | Where-Object { $_.label -eq $taskLabel }

    if (-not $existingTask) {
      Write-Host "Updating tasks.json for $command in $vscodeDir"
      $newTask = [PSCustomObject]@{
        label        = "$taskLabel"
        type         = "shell"
        command      = "$command"
        args         = @($cmdArgs)
        isBackground = $true
        presentation = @{
          panel  = "dedicated"
          reveal = "always"
        }
        runOptions   = @{
          runOn = "folderOpen"
        }
      }
      $jsonContent.tasks += $newTask
      $jsonContent | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $tasksFile
    }
    else {
      # Write-Host "Task $taskLabel already exists."
    }
  }
}