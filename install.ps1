<#
.SYNOPSIS
  Install the principles-driven skill suite on Windows.
.DESCRIPTION
  Run from a cloned repo:
    git clone https://github.com/ccr-hk/principles-driven.git
    cd principles-driven; .\install.ps1
  Targets (default = interactive prompt):
    -Agents            ~\.agents\skills   (Codex, Antigravity, any SKILL.md tool)
    -Claude            ~\.claude\skills   (Claude Code)
    -Cursor <dir>      <dir>\.cursor\rules (Cursor project rules; repeatable)
    -All               -Agents and -Claude
  Options: -Symlink (default: copy), -Register, -NoRegister
#>
[CmdletBinding()]
param(
  [switch]$Agents, [switch]$Claude, [switch]$All,
  [string[]]$Cursor = @(),
  [switch]$Symlink, [switch]$Register, [switch]$NoRegister
)
$ErrorActionPreference = "Stop"
$Root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src    = Join-Path $Root "skills"
$Skills = @("principles-driven","principles-review","principles-check","principles-audit","principles-update")
$Version = (Get-Content (Join-Path $Root "VERSION") -ErrorAction SilentlyContinue | Select-Object -First 1)
if (-not $Version) { $Version = "unknown" }

$AgentsDir = if ($env:AGENTS_SKILLS_DIR) { $env:AGENTS_SKILLS_DIR } else { Join-Path $env:USERPROFILE ".agents\skills" }
$ClaudeDir = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path $env:USERPROFILE ".claude\skills" }
$ConfigDir = Join-Path $env:APPDATA "principles-driven"

$doAgents = $Agents -or $All
$doClaude = $Claude -or $All
$mode = if ($Symlink) { "symlink" } else { "copy" }

if (-not $doAgents -and -not $doClaude -and $Cursor.Count -eq 0) {
  Write-Host "Where should the principles-driven skills be installed?"
  Write-Host "  1) Universal  (~\.agents\skills - Codex, Antigravity)"
  Write-Host "  2) Claude Code (~\.claude\skills)"
  Write-Host "  3) Both 1 and 2  [default]"
  Write-Host "  4) Universal + a Cursor project"
  $choice = Read-Host "Choice [3]"
  switch ($choice) {
    "1" { $doAgents = $true }
    "2" { $doClaude = $true }
    "4" { $doAgents = $true; $Cursor += (Read-Host "Cursor project path") }
    default { $doAgents = $true; $doClaude = $true }
  }
}

function Install-Skills($dest) {
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  foreach ($s in $Skills) {
    $target = Join-Path $dest $s
    if (Test-Path $target) { Remove-Item -Recurse -Force $target }
    if ($mode -eq "symlink") {
      New-Item -ItemType SymbolicLink -Path $target -Target (Join-Path $Src $s) | Out-Null
    } else {
      Copy-Item -Recurse -Force (Join-Path $Src $s) $target
    }
  }
  Write-Host "  $mode -> $dest  ($($Skills.Count) skills)"
}
function Install-Cursor($proj) {
  if (-not (Test-Path $proj -PathType Container)) { Write-Warning "skip cursor: '$proj' not a directory"; return }
  $dest = Join-Path $proj ".cursor\rules"
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item -Force (Join-Path $Root "dist\cursor\*.mdc") $dest
  Write-Host "  copy  -> $dest"
}

$targets = @()
Write-Host "Installing principles-driven v$Version"
if ($doAgents) { Install-Skills $AgentsDir; $targets += "agents:$AgentsDir" }
if ($doClaude) { Install-Skills $ClaudeDir; $targets += "claude:$ClaudeDir" }
foreach ($d in $Cursor) { if ($d) { Install-Cursor $d; $targets += "cursor:$d\.cursor\rules" } }

# optional pointer registration
$pointer = @"
<!-- principles-driven:begin -->
## Principles-driven skills
This project/user has the **principles-driven** skill suite installed. When a
task involves the project's guiding principles or a judgment call:
- create/edit principles or inherit a repo -> use **principles-review**
- about to make a judgment call, or reviewing a diff -> use **principles-check**
- whole-codebase consistency sweep -> use **principles-audit**
- check for updates to these skills -> use **principles-update**
On every judgment call covered by ``PRINCIPLES.md``, honor it; on a conflict, stop
and surface options rather than deciding silently.
<!-- principles-driven:end -->
"@
$candidates = @(
  (Join-Path $env:USERPROFILE ".codex\AGENTS.md"),
  (Join-Path $env:USERPROFILE ".gemini\GEMINI.md"),
  (Join-Path $env:USERPROFILE ".claude\CLAUDE.md")
)
$present = $candidates | Where-Object { Test-Path $_ }
if ($present.Count -gt 0) {
  $reg = $false
  if ($Register) { $reg = $true }
  elseif ($NoRegister) { $reg = $false }
  else {
    Write-Host ""
    Write-Host "Found instruction files that could announce these skills:"
    $present | ForEach-Object { Write-Host "  - $_" }
    $ans = Read-Host "Append a principles-driven pointer to them? [y/N]"
    $reg = ($ans -eq "y" -or $ans -eq "Y")
  }
  if ($reg) {
    foreach ($f in $present) {
      if (Select-String -Path $f -Pattern "principles-driven:begin" -Quiet) { Write-Host "  pointer already present in $f" }
      else { Add-Content -Path $f -Value "`n$pointer"; Write-Host "  appended pointer -> $f" }
    }
  } else { Write-Host "  (skipped instruction-file registration)" }
}

# manifest
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
$repo = (& git -C $Root config --get remote.origin.url) 2>$null
if (-not $repo) { $repo = "https://github.com/ccr-hk/principles-driven" }
$method = if (Test-Path (Join-Path $Root ".git")) { "clone" } else { "copy" }
@(
  "version=$Version",
  "repo=$repo",
  "clone_path=$Root",
  "method=$method",
  "targets=$([string]::Join(',', $targets))",
  "install_mode=$mode",
  "installed_at=$((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
) | Set-Content -Path (Join-Path $ConfigDir "manifest.txt")

Write-Host ""
Write-Host "Done. v$Version installed. Manifest: $(Join-Path $ConfigDir 'manifest.txt')"
Write-Host "Start a new agent session and try: principles-driven"
