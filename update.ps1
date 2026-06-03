<#
.SYNOPSIS
  Update an existing principles-driven install on Windows: pull latest and
  re-install into the same targets recorded in the manifest.
.EXAMPLE
  cd <clone>; .\update.ps1
#>
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigDir = Join-Path $env:APPDATA "principles-driven"
$Manifest = Join-Path $ConfigDir "manifest.txt"

function Get-Field($name) {
  if (-not (Test-Path $Manifest)) { return $null }
  $line = Select-String -Path $Manifest -Pattern "^$name=" | Select-Object -First 1
  if ($line) { return ($line.Line -replace "^$name=", "") } else { return $null }
}

$old = Get-Field "version"; if (-not $old) { $old = "unknown" }
if (Test-Path (Join-Path $Root ".git")) {
  Write-Host "Pulling latest in $Root ..."
  git -C $Root pull --ff-only
}
$new = (Get-Content (Join-Path $Root "VERSION") -ErrorAction SilentlyContinue | Select-Object -First 1)
if (-not $new) { $new = "unknown" }
Write-Host "Version: $old -> $new"

# reconstruct flags from manifest
$flagArgs = @()
if ((Get-Field "install_mode") -eq "symlink") { $flagArgs += "-Symlink" }
$targets = Get-Field "targets"
$cursorProjects = @()
if ($targets) {
  foreach ($p in $targets.Split(",")) {
    if ($p -like "agents:*") { $flagArgs += "-Agents"; $env:AGENTS_SKILLS_DIR = ($p -replace "^agents:", "") }
    elseif ($p -like "claude:*") { $flagArgs += "-Claude"; $env:CLAUDE_SKILLS_DIR = ($p -replace "^claude:", "") }
    elseif ($p -like "cursor:*") {
      $proj = ($p -replace "^cursor:", "") -replace "\\.cursor\\rules$", ""
      $cursorProjects += $proj
    }
  }
}
$flagArgs += "-NoRegister"

$installArgs = @{}
if ($flagArgs -contains "-Agents")    { $installArgs["Agents"] = $true }
if ($flagArgs -contains "-Claude")    { $installArgs["Claude"] = $true }
if ($flagArgs -contains "-Symlink")   { $installArgs["Symlink"] = $true }
$installArgs["NoRegister"] = $true
if ($cursorProjects.Count -gt 0)      { $installArgs["Cursor"] = $cursorProjects }

Write-Host "Re-installing..."
& (Join-Path $Root "install.ps1") @installArgs
Write-Host "Update complete: now at v$new"
