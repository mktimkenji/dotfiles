# ============================================================
# bootstrap.ps1 - Windows orchestrator
# Run as a normal user - no Admin required except for the
# WezTerm symlink step at the very end.
#
# Prerequisites:
#   1. WSL installed and PC rebooted if first time (wsl --install, then reboot)
#   2. Execution policy set: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#   3. bootstrap.env filled in (copy from bootstrap.env.example)
#
# Usage (normal PowerShell, no Admin):
#   .\bootstrap.ps1
# ============================================================
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -- Resolve paths ------------------------------------------------------------
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot    = Split-Path -Parent $ScriptDir
$EnvFile     = Join-Path $ScriptDir "bootstrap.env"
$SentinelWin = Join-Path $RepoRoot ".bootstrap_complete"
$WinLogFile  = Join-Path $RepoRoot ".bootstrap_win.log"

# -- Helpers ------------------------------------------------------------------
function Write-Phase {
    param([string]$Msg)
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  $Msg" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
}
function Write-Ok   { param([string]$Msg) Write-Host "  [OK] $Msg" -ForegroundColor Green   }
function Write-Skip { param([string]$Msg) Write-Host "  [--] $Msg" -ForegroundColor DarkGray }
function Write-Warn { param([string]$Msg) Write-Host "  [!!] $Msg" -ForegroundColor Yellow  }
function Write-Fail { param([string]$Msg) Write-Host "  [XX] $Msg" -ForegroundColor Red     }
function Log-Win {
    param([string]$Msg)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $Msg" | Add-Content -Path $WinLogFile
}

# Helper: run a wsl command and capture exit code without letting
# $ErrorActionPreference = Stop kill the script on non-zero returns.
function Invoke-Wsl {
    param([string[]]$Arguments)
    $ErrorActionPreference = "Continue"
    $null = wsl @Arguments 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = "Stop"
    return $code
}

# -- Sentinel guard -----------------------------------------------------------
Write-Phase "Checking bootstrap sentinel"
if (Test-Path $SentinelWin) {
    Write-Fail "Sentinel file found at $SentinelWin"
    Write-Fail "Bootstrap appears to have already completed."
    Write-Warn "Delete .bootstrap_complete manually if you want to re-run."
    exit 1
}
Write-Ok "No sentinel found - proceeding."

# -- Load and validate bootstrap.env -----------------------------------------
Write-Phase "Loading bootstrap.env"
if (-not (Test-Path $EnvFile)) {
    Write-Fail "bootstrap.env not found at $EnvFile"
    Write-Fail "Copy bootstrap.env.example to bootstrap.env and fill in your values."
    exit 1
}

$Config = @{}
Get-Content $EnvFile | Where-Object { $_ -match '^\s*[^#]\w+=.+' } | ForEach-Object {
    $parts = $_ -split '=', 2
    $Config[$parts[0].Trim()] = $parts[1].Trim()
}

$Required = @("WSL_DISTRO", "WSL_USERNAME", "WSL_PASSWORD", "GIT_NAME", "GIT_EMAIL")
foreach ($key in $Required) {
    if (-not $Config.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($Config[$key])) {
        Write-Fail "Missing required value: $key"
        exit 1
    }
}

$WslDistro   = $Config["WSL_DISTRO"]
$WslUser     = $Config["WSL_USERNAME"]
$WslPassword = $Config["WSL_PASSWORD"]
$GitName     = $Config["GIT_NAME"]
$GitEmail    = $Config["GIT_EMAIL"]

Write-Ok "bootstrap.env loaded and validated."

# -- Phase 1: Scoop -----------------------------------------------------------
Write-Phase "Phase 1 - Scoop"

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Write-Ok "Execution policy set."

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Scoop..."
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                $env:PATH
    Write-Ok "Scoop installed."
    Log-Win "PHASE 1 DONE: Scoop installed"
} else {
    Write-Skip "Scoop already installed."
    Log-Win "PHASE 1 SKIP: Scoop already present"
}

# -- Phase 2: WezTerm and Nerd Font ------------------------------------------
Write-Phase "Phase 2 - WezTerm (nightly) and JetBrainsMono NF"

$ScoopBuckets = scoop bucket list 2>$null |
    ForEach-Object { "$_".Trim() } |
    ForEach-Object { ($_ -split '\s+')[0] }

if ($ScoopBuckets -notcontains "versions") {
    scoop bucket add versions
    Write-Ok "Added versions bucket."
} else { Write-Skip "versions bucket already present." }

if ($ScoopBuckets -notcontains "nerd-fonts") {
    scoop bucket add nerd-fonts
    Write-Ok "Added nerd-fonts bucket."
} else { Write-Skip "nerd-fonts bucket already present." }

$ScoopApps = scoop list 2>$null |
    ForEach-Object { "$_".Trim() } |
    ForEach-Object { ($_ -split '\s+')[0] }

if ($ScoopApps -notcontains "wezterm-nightly") {
    scoop install wezterm-nightly
    Write-Ok "WezTerm nightly installed."
} else { Write-Skip "WezTerm nightly already installed." }

if ($ScoopApps -notcontains "JetBrainsMono-NF") {
    scoop install JetBrainsMono-NF
    Write-Ok "JetBrainsMono NF installed."
} else { Write-Skip "JetBrainsMono NF already installed." }

Log-Win "PHASE 2 DONE: WezTerm and fonts"

# -- Phase 3: WSL2 update and config -----------------------------------------
Write-Phase "Phase 3 - WSL2"

wsl --update
Write-Ok "WSL2 updated."

$WslConfigPath = Join-Path $env:USERPROFILE ".wslconfig"
if (-not (Test-Path $WslConfigPath)) {
    $WslConfigContent = @"
[wsl2]
memory=12GB
processors=8
swap=8GB
networkingMode=mirrored
"@
    Set-Content -Path $WslConfigPath -Value $WslConfigContent
    Write-Ok ".wslconfig created."
} else {
    Write-Skip ".wslconfig already exists - not overwriting."
}

Log-Win "PHASE 3 DONE: WSL2 configured"

# -- Phase 4: Install Fedora and create user ----------------------------------
Write-Phase "Phase 4 - Fedora WSL distro"

$InstalledDistros = (wsl --list --quiet 2>$null) -replace "`0", "" |
    Where-Object { $_ -ne "" }

if ($InstalledDistros -notcontains $WslDistro) {
    Write-Host "  Installing $WslDistro - this may take a few minutes..."
    wsl --install $WslDistro --no-launch
    Write-Ok "$WslDistro installed."
} else {
    Write-Skip "$WslDistro already installed."
}

# Create user non-interactively as root.
# No password set here - chpasswd runs at the very end of bootstrap.sh
# after everything is installed, keeping this phase fully unattended.
Write-Host "  Checking WSL user '$WslUser'..."
$userCheckCode = Invoke-Wsl @("-d", $WslDistro, "-u", "root", "--", "id", "-u", $WslUser)

if ($userCheckCode -ne 0) {
    wsl -d $WslDistro -u root -- useradd -m -s /bin/bash $WslUser
    wsl -d $WslDistro -u root -- usermod -aG wheel $WslUser

    # Passwordless sudo so bootstrap.sh runs fully unattended
    wsl -d $WslDistro -u root -- bash -c `
        "echo '$WslUser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$WslUser && chmod 0440 /etc/sudoers.d/$WslUser"

    # Disable automount (suppresses failed mount errors for non-NTFS drives),
    # register only C: via fstab so WSL still has access to Windows files.
    $WslConf = "[user]\ndefault=$WslUser\n\n[automount]\nenabled=false\nmountFsTab=true\n\n[boot]\nsystemd=true\n"
    wsl -d $WslDistro -u root -- bash -c "printf '$WslConf' > /etc/wsl.conf"
    wsl -d $WslDistro -u root -- bash -c `
        "mkdir -p /mnt/c && echo 'C: /mnt/c drvfs defaults,uid=1000,gid=1000,metadata 0 0' >> /etc/fstab"

    Write-Ok "User '$WslUser' created (no password yet - set at end of bootstrap)."
    Write-Ok "Automount disabled - only C: will mount via fstab."
} else {
    Write-Skip "User '$WslUser' already exists."
}

wsl --terminate $WslDistro
Start-Sleep -Seconds 2
Write-Ok "$WslDistro restarted with new mount rules."

Log-Win "PHASE 4 DONE: Fedora distro and user created"

# -- Phase 5: Clone dotfiles into WSL ----------------------------------------
Write-Phase "Phase 5 - Clone dotfiles into WSL"

$gitCheckCode = Invoke-Wsl @("-d", $WslDistro, "-u", $WslUser, "--", "test", "-d", "/home/$WslUser/dotfiles/.git")

if ($gitCheckCode -ne 0) {
    Write-Host "  Installing git in WSL..."
    wsl -d $WslDistro -u root -- dnf install -y git | Out-Null
    Write-Host "  Cloning dotfiles repository..."
    # Public repo - no credentials needed
    wsl -d $WslDistro -u $WslUser -- git clone https://github.com/prodicty/dotfiles.git /home/$WslUser/dotfiles
    Write-Ok "Dotfiles cloned to ~/dotfiles."
} else {
    Write-Skip "Dotfiles repo already present in WSL."
}

Log-Win "PHASE 5 DONE: dotfiles cloned into WSL"

# -- Phase 6: Detect GCM and hand off to bootstrap.sh ------------------------
Write-Phase "Phase 6 - Handing off to bootstrap.sh (Linux)"

$GcmWslPath = ""
$GitExe = Get-Command git -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if ($GitExe) {
    $GitRoot = Split-Path -Parent (Split-Path -Parent $GitExe)
    $GcmPath = Join-Path $GitRoot "mingw64\bin\git-credential-manager.exe"
    if (Test-Path $GcmPath) {
        $ErrorActionPreference = "Continue"
        $GcmWslPath = (wsl -d $WslDistro -- wslpath -u "$GcmPath" 2>$null).Trim()

        if ($GcmWslPath) {
          $GcmWslPath = "!`"$GcmWslPath`""
        }

        $ErrorActionPreference = "Stop"
        Write-Ok "GCM found - will configure in WSL."
    } else {
        Write-Warn "GCM not found at expected path - credential helper will be skipped."
    }
} else {
    Write-Warn "Git not found on Windows PATH - credential helper will be skipped."
}

$BootstrapArgs = @(
    "--git-name",  $GitName,
    "--git-email", $GitEmail,
    "--password",  $WslPassword
)
if ($GcmWslPath) {
    $BootstrapArgs += "--git-credential-helper"
    $BootstrapArgs += $GcmWslPath
}

Write-Host "  Invoking bootstrap.sh inside WSL..."
Write-Host "  This will take a while - safe to leave unattended."
Write-Host ""

$BootstrapSh = "/home/$WslUser/dotfiles/fedora-wsl/bootstrap.sh"

$ErrorActionPreference = "Continue"
wsl -d $WslDistro -u $WslUser -- bash $BootstrapSh @BootstrapArgs
$bootstrapExitCode = $LASTEXITCODE
$ErrorActionPreference = "Stop"

if ($bootstrapExitCode -ne 0) {
    Write-Fail "bootstrap.sh exited with code $bootstrapExitCode"
    Write-Fail "Check ~/.bootstrap_log inside WSL for details."
    Log-Win "PHASE 6 FAILED: bootstrap.sh exit code $bootstrapExitCode"
    exit 1
}

Log-Win "PHASE 6 DONE: Linux bootstrap complete"

# -- Phase 7: WezTerm config symlink (Admin required, done last) -------------
Write-Phase "Phase 7 - WezTerm config symlink"

$WeztermConfigDir = Join-Path $env:USERPROFILE ".config\wezterm"
$WeztermTarget    = "\\wsl$\$WslDistro\home\$WslUser\dotfiles\wezterm\.config\wezterm"

if (-not (Test-Path $WeztermConfigDir)) {
    Write-Host "  Creating symlink - a UAC prompt will appear now..."
    $MklinkCmd = "mklink /D `"$WeztermConfigDir`" `"$WeztermTarget`""
    Start-Process cmd -Verb RunAs -ArgumentList "/c $MklinkCmd" -Wait
    if (Test-Path $WeztermConfigDir) {
        Write-Ok "WezTerm symlink created."
    } else {
        Write-Warn "Symlink may not have been created - check $WeztermConfigDir manually."
        Write-Warn "Run manually: mklink /D `"$WeztermConfigDir`" `"$WeztermTarget`""
    }
} else {
    Write-Skip "WezTerm config path already exists - not overwriting."
}

Log-Win "PHASE 7 DONE: WezTerm symlink"

# -- Done ---------------------------------------------------------------------
Write-Phase "Bootstrap complete"
Write-Ok "All phases complete."
Write-Ok "Restart WezTerm to pick up the new configuration."
Write-Host ""
Log-Win "BOOTSTRAP COMPLETE"
