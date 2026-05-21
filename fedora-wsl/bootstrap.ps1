# ============================================================
# bootstrap.ps1 — Windows orchestrator
# Run from an elevated (Admin) PowerShell session.
# Prerequisites: git installed on Windows, dotfiles repo cloned.
# ============================================================
#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Resolve repo root (script lives in fedorawsl/ inside the repo) ───────────
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot   = Split-Path -Parent $ScriptDir
$EnvFile    = Join-Path $ScriptDir "bootstrap.env"
$SentinelWin = Join-Path $RepoRoot ".bootstrap_complete"

# ── Helper: pretty-print phase headers ───────────────────────────────────────
function Write-Phase {
    param([string]$Msg)
    Write-Host ""
    Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Msg" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
}

function Write-Ok   { param([string]$Msg) Write-Host "  [OK] $Msg" -ForegroundColor Green  }
function Write-Skip { param([string]$Msg) Write-Host "  [--] $Msg" -ForegroundColor DarkGray }
function Write-Warn { param([string]$Msg) Write-Host "  [!!] $Msg" -ForegroundColor Yellow }
function Write-Fail { param([string]$Msg) Write-Host "  [XX] $Msg" -ForegroundColor Red    }

# ── Sentinel guard ────────────────────────────────────────────────────────────
Write-Phase "Checking bootstrap sentinel"
if (Test-Path $SentinelWin) {
    Write-Fail "Sentinel file found at $SentinelWin"
    Write-Fail "Bootstrap appears to have already completed."
    Write-Warn "Delete .bootstrap_complete manually if you intentionally want to re-run."
    exit 1
}
Write-Ok "No sentinel found — proceeding."

# ── Load and validate bootstrap.env ──────────────────────────────────────────
Write-Phase "Loading bootstrap.env"
if (-not (Test-Path $EnvFile)) {
    Write-Fail "bootstrap.env not found at $EnvFile"
    Write-Fail "Copy bootstrap.env.example to bootstrap.env and fill in your values."
    exit 1
}

$Env = @{}
Get-Content $EnvFile | Where-Object { $_ -match '^\s*[^#]\w+=.+' } | ForEach-Object {
    $parts = $_ -split '=', 2
    $Env[$parts[0].Trim()] = $parts[1].Trim()
}

$Required = @("WSL_DISTRO", "WSL_USERNAME", "WSL_PASSWORD", "GIT_NAME", "GIT_EMAIL")
foreach ($key in $Required) {
    if (-not $Env.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($Env[$key])) {
        Write-Fail "Missing required value: $key"
        exit 1
    }
}

$WslDistro   = $Env["WSL_DISTRO"]
$WslUser     = $Env["WSL_USERNAME"]
$WslPassword = $Env["WSL_PASSWORD"]
$GitName     = $Env["GIT_NAME"]
$GitEmail    = $Env["GIT_EMAIL"]

Write-Ok "bootstrap.env loaded and validated."

# ── Phase 1: Scoop ────────────────────────────────────────────────────────────
Write-Phase "Phase 1 — Scoop"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    Write-Ok "Scoop installed."
} else {
    Write-Skip "Scoop already installed."
}

# ── Phase 2: WezTerm and Nerd Font ───────────────────────────────────────────
Write-Phase "Phase 2 — WezTerm (nightly) and JetBrainsMono NF"

$ScoopBuckets = scoop bucket list | ForEach-Object { $_.Trim() }

if ($ScoopBuckets -notcontains "versions") {
    scoop bucket add versions
    Write-Ok "Added 'versions' bucket."
} else { Write-Skip "'versions' bucket already present." }

if ($ScoopBuckets -notcontains "nerd-fonts") {
    scoop bucket add nerd-fonts
    Write-Ok "Added 'nerd-fonts' bucket."
} else { Write-Skip "'nerd-fonts' bucket already present." }

$ScoopApps = scoop list 2>$null | ForEach-Object { ($_ -split '\s+')[0].Trim() }

if ($ScoopApps -notcontains "wezterm-nightly") {
    scoop install wezterm-nightly
    Write-Ok "WezTerm nightly installed."
} else { Write-Skip "WezTerm nightly already installed." }

if ($ScoopApps -notcontains "JetBrainsMono-NF") {
    scoop install JetBrainsMono-NF
    Write-Ok "JetBrainsMono NF installed."
} else { Write-Skip "JetBrainsMono NF already installed." }

# ── Phase 3: WSL2 ─────────────────────────────────────────────────────────────
Write-Phase "Phase 3 — WSL2"
wsl --install --no-distribution
wsl --update
$WslStatus = wsl --status 2>&1
Write-Ok "WSL2 updated."

$WslConfigPath = Join-Path $env:USERPROFILE ".wslconfig"
if (-not (Test-Path $WslConfigPath)) {
    @"
[wsl2]
memory=12GB
processors=8
swap=8GB
networkingMode=mirrored
"@ | Set-Content $WslConfigPath
    Write-Ok ".wslconfig created."
} else {
    Write-Skip ".wslconfig already exists — not overwriting."
}

# ── Phase 4: Install Fedora distro and create user ───────────────────────────
Write-Phase "Phase 4 — Fedora WSL distro"

$InstalledDistros = wsl --list --quiet 2>$null
if ($InstalledDistros -notcontains $WslDistro) {
    Write-Host "  Installing $WslDistro — this may take a few minutes..."
    wsl --install $WslDistro --no-launch
    Write-Ok "$WslDistro installed."
} else {
    Write-Skip "$WslDistro already installed."
}

# First launch with root to create user non-interactively
Write-Host "  Creating WSL user '$WslUser'..."
$UserExists = wsl -d $WslDistro -u root -- id -u $WslUser 2>$null
if ($LASTEXITCODE -ne 0) {

    wsl -d $WslDistro -u root -- useradd -m -s /bin/bash $WslUser
    wsl -d $WslDistro -u root -- bash -c "echo '${WslUser}:${WslPassword}' | chpasswd"
    wsl -d $WslDistro -u root -- usermod -aG wheel $WslUser

    # Set as default user via /etc/wsl.conf
    wsl -d $WslDistro -u root -- bash -c @"
cat >> /etc/wsl.conf << 'EOF'
[user]
default=$WslUser
EOF
"@
    Write-Ok "User '$WslUser' created and set as default."
} else {
    Write-Skip "User '$WslUser' already exists."
}

# Restart the distro so wsl.conf default user takes effect
wsl --terminate $WslDistro
Start-Sleep -Seconds 2
Write-Ok "$WslDistro restarted."

# ── Phase 5: Clone dotfiles into WSL ─────────────────────────────────────────
Write-Phase "Phase 5 — Clone dotfiles into WSL"

$DotfilesExists = wsl -d $WslDistro -u $WslUser -- test -d "~/dotfiles/.git" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Installing git in WSL..."
    wsl -d $WslDistro -u root -- dnf install -y git | Out-Null

    Write-Host "  Cloning dotfiles repository..."
    # Public repo — no credentials needed
    wsl -d $WslDistro -u $WslUser -- git clone https://github.com/prodicty/dotfiles.git /home/$WslUser/dotfiles
    Write-Ok "Dotfiles cloned to ~/dotfiles."
} else {
    Write-Skip "Dotfiles repo already present in WSL."
}

# ── Phase 6: WezTerm config symlink (Windows → WSL dotfiles) ─────────────────
Write-Phase "Phase 6 — WezTerm config symlink"

$WeztermConfigDir = Join-Path $env:USERPROFILE ".config\wezterm"
$WeztermTarget    = "\\wsl$\$WslDistro\home\$WslUser\dotfiles\wezterm\.config\wezterm"

if (-not (Test-Path $WeztermConfigDir)) {
    cmd /c "mklink /D `"$WeztermConfigDir`" `"$WeztermTarget`""
    Write-Ok "WezTerm symlink created: $WeztermConfigDir -> $WeztermTarget"
} else {
    Write-Skip "WezTerm config path already exists — not overwriting."
}

# ── Phase 7: Hand off to bootstrap.sh inside WSL ─────────────────────────────
Write-Phase "Phase 7 — Handing off to bootstrap.sh (Linux)"

$BootstrapSh = "/home/$WslUser/dotfiles/fedora-wsl/bootstrap.sh"
Write-Host "  Invoking: $BootstrapSh"
Write-Host "  All further output is from the Linux bootstrap script."
Write-Host ""

wsl -d $WslDistro -u $WslUser -- bash $BootstrapSh `
    --git-name "$GitName" `
    --git-email "$GitEmail"

if ($LASTEXITCODE -ne 0) {
    Write-Fail "bootstrap.sh exited with code $LASTEXITCODE — check ~/.bootstrap_log inside WSL."
    exit 1
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Phase "Bootstrap complete"
Write-Ok "Windows phases complete. Linux phases complete."
Write-Ok "Restart WezTerm to pick up the new configuration."
