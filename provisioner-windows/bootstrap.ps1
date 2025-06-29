<#
.SYNOPSIS
    Standalone Invokeable Script to download this repository
    on a fresh windows machine (no git pre-required).
.EXAMPLE
  See README ("Git-free install")
#>

### Constants
$Account = "JonasPammer"
$Repository = "JonasPammer"
$Branch = "master"
$ParentDestination = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Programmieren"
$SubfolderToOpen = "provisioner-windows"


### Functions
# ~ replica of function found in utils.ps1:
function Show-Output() {
  Write-Host "[bootstrap.ps1] $args" -BackgroundColor White -ForegroundColor Black
}

# replica of function found in utils.ps1:
function Test-CommandExists {
  [OutputType([bool])]
  Param(
    [Parameter(Mandatory = $true)][string]$command
  )
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = "stop"
  try {
    if (Get-Command $command) { RETURN $true }
  }
  catch { return $false }
  finally { $ErrorActionPreference = $oldPreference }
}

# replica of function found in utils.ps1:
function Update-PathEnvironmentVariable() {
  Show-Output "Refreshing PATH Environment Variable.."
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
  if (Test-CommandExists "refreshenv") { try { refreshenv } catch { } }
}

# replica of function found in utils.ps1:
function Test-Admin {
  [OutputType([bool])]
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  return $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# replica of function found in utils.ps1:
function Elevate {
  Param(
    [Parameter(Mandatory = $true)][string]$command
  )
  if (! (Test-Admin)) {
    if ($elevated) {
      Show-Output "Elevation did not work."
    }
    else {
      Show-Output "This script requires admin access. Elevating."
      Show-Output "$command"
      # Use newer PowerShell if available.
      if (Test-CommandExists "pwsh") { $shell = "pwsh" } else { $shell = "powershell" }
      Start-Process -FilePath "$shell" -Verb RunAs -ArgumentList ('-NoProfile -NoExit -Command "cd {0}; {1}" -elevated' -f ($pwd, $command))
      Show-Output "The script has been started in another window. You can close this window now."
    }
    exit
  }
  Show-Output "Running as Administrator!"
}


### Main
Elevate($MyInvocation.MyCommand.Definition)

if (!Test-CommandExists "choco") {
  # replica of "Install-Chocolatey" function found in utils.ps1:
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  Update-PathEnvironmentVariable
}

if (!Test-CommandExists "git") {
  choco upgrade git -y
  Update-PathEnvironmentVariable
}

New-Item -ItemType Directory -Path $ParentDestination -Force | Out-Null
if (Test-Path "$ParentDestination\$Repository") {
  Set-Location "$ParentDestination\$Repository"
  git checkout $Branch
  Show-Output "Performing 'git pull' to update the scripts."
  git pull
} else {
  Set-Location "$ParentDestination"
  git clone "https://github.com/$Account/$Repository"
  Set-Location "$ParentDestination\$Repository"
  Show-Output "Checking out the correct Branch."
  git checkout $Branch
}
git config --global --add safe.directory "$ParentDestination\$Repository"

Set-ExecutionPolicy Bypass -Scope Process -Force
Push-Location "$ParentDestination\$Repository\$SubfolderToOpen"
Show-Output "You can now execute: \n\n \t./pc-setup.ps1"
# if (Get-Command "wt" -ErrorAction SilentlyContinue) { Start-Process "wt" -ArgumentList "-d `"$ParentDestination\$Repository`"" } else { Start-Process (if (Get-Command "pwsh" -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell" }) -ArgumentList "-NoExit", "-Command", "Set-Location '$ParentDestination\$Repository'" }
