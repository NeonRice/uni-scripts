Param (
  [string]$User = $env:USERNAME,

  [switch]$FilterUser = $false,

  [string]$LogDirectory = [System.Environment]::GetFolderPath("MyDocuments"),

  [switch]$NoOpen = $false,

  [string]$EditorPath = "notepad.exe"
)

$CurrentDate = Get-Date
$UserProcesses = @{}
$NonUserProcesses = [System.Collections.ArrayList]::new()

Function Add-LogContent ($Path, $Processes) {
  if (-not (Test-Path $Path)) {
    New-Item $Path > $null
  }
  $Time = $CurrentDate.ToString("HH:mm:ss")
  $Date = $CurrentDate.ToString("dddd yyyy/MM/dd") 
  $File = [System.IO.StreamWriter]::new($Path)
  $File.WriteLine("$Date`n$Time`n")

  foreach ($Process in $Processes) {
    $File.WriteLine("Name: $($Process.Name)`nPID: $($Process.ID)")
    $File.WriteLine("Desc: $($Process.Description)`nPath: $($Process.Path)")
    $File.WriteLine("RAM: $([System.Math]::Round($Process.WorkingSet / 1MB, 2)) MB")
    $File.WriteLine("CPU Time: $($Process.CPU)`n")
  }
  $File.Close()
  return $Path
}

Function Log-Processes ($User = $NULL) {
  $Username = "NonUser"
  $Processes = $NonUserProcesses
  if ($User -ne $NULL) {
    $Username = $User
    $Processes = $UserProcesses[$Username]
  }   
  $Time = $CurrentDate.ToString("s").Replace(":", "")
  $FileTemplate = "$($Username)-process-log-$($Time).txt"

  $LogPath = Join-Path $LogDirectory -ChildPath $FileTemplate
  return Add-LogContent -Path $LogPath -Processes $Processes 
}

if (-not (Test-Path $LogDirectory)) {
  Write-Error "Given path $LogDirectory does not exist"
  exit
}

# If Path leads to file, take the directory
if (Test-Path $LogDirectory -PathType Leaf) {
  $LogDirectory = Split-Path $LogDirectory -Parent
}

# Add Process info into specific arrays
foreach ($Process in Get-Process -IncludeUserName) {
  if ([string]::IsNullOrEmpty($Process.UserName)) {
    $NonUserProcesses.Add($Process) > $null
    continue
  }
  $Process.UserName = $Process.UserName.Split("\")[1]

  if (!$UserProcesses.ContainsKey($Process.UserName)) {
    $UserProcesses[$Process.UserName] = [System.Collections.ArrayList]::new()
  }   
  $UserProcesses[$Process.UserName].Add($Process) > $null
}

$LogFiles = @()
if ($FilterUser) {
  $LogFiles += Log-Processes -User $User
} else {
  foreach ($User in $UserProcesses.Keys) {
    $LogFiles += Log-Processes -User $User
  }
  Log-Processes -User $NULL
}

Write-Host "Created log files:"
$LogFiles

if ($NoOpen) {
  $LASTEXITCODE = 0
  exit
}

if (-not [bool](Get-Command $EditorPath)) {
  $LASTEXITCODE = -1
  Write-Error "Bad editor path"
  exit
}

$StartedProcesses = @()
foreach ($LogFile in $LogFiles) {
  $StartedProcesses += Start-Process -FilePath "$EditorPath" -ArgumentList "$LogFile" -PassThru
}

Read-Host -Prompt "Press any key to close open notepads"
foreach ($StartedProcess in $StartedProcesses) {
  if ($StartedProcess.HasExited) { continue }
  $StartedProcess.Kill() > $null
}
