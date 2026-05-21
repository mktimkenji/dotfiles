#!/usr/bin/env bash
# ============================================================
# bootstrap.sh — Linux worker script
# Invoked once by bootstrap.ps1 via a single wsl.exe call.
# Can also be run standalone for the Linux phases only.
# ============================================================
set -euo pipefail

# ── Argument parsing ──────────────────────────────────────────────────────────
GIT_NAME=""
GIT_EMAIL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --git-name)
    GIT_NAME="$2"
    shift 2
    ;;
  --git-email)
    GIT_EMAIL="$2"
    shift 2
    ;;
  *)
    echo "[XX] Unknown argument: $1"
    exit 1
    ;;
  esac
done

if [[ -z "$GIT_NAME" || -z "$GIT_EMAIL" ]]; then
  echo "[XX] --git-name and --git-email are required."
  exit 1
fi

# ── Paths ─────────────────────────────────────────────────────────────────────
DOTFILES_DIR="$HOME/dotfiles"
SENTINEL="$DOTFILES_DIR/.bootstrap_complete"
LOG="$DOTFILES_DIR/.bootstrap_log"

# ── Logging helpers ───────────────────────────────────────────────────────────
log() { echo "$(date '+%Y-%m-%d %H:%M:%S')  $*" | tee -a "$LOG"; }
phase() {
  echo ""
  echo "══════════════════════════════════════════" | tee -a "$LOG"
  echo "  $*" | tee -a "$LOG"
  echo "══════════════════════════════════════════" | tee -a "$LOG"
}
ok() { echo "  [OK] $*" | tee -a "$LOG"; }
skip() { echo "  [--] $*" | tee -a "$LOG"; }
warn() { echo "  [!!] $*" | tee -a "$LOG"; }
fail() { echo "  [XX] $*" | tee -a "$LOG"; }

# ── Error trap ────────────────────────────────────────────────────────────────
trap 'fail "Script failed at line $LINENO — check $LOG for details."' ERR

# ── Sentinel guard ────────────────────────────────────────────────────────────
phase "Checking bootstrap sentinel"
if [[ -f "$SENTINEL" ]]; then
  fail "Sentinel file found at $SENTINEL"
  fail "Bootstrap appears to have already completed."
  warn "Delete .bootstrap_complete manually if you intentionally want to re-run."
  exit 1
fi
ok "No sentinel found — proceeding."
log "Bootstrap started. git-name='$GIT_NAME' git-email='$GIT_EMAIL'"

# ── Idempotency helper ────────────────────────────────────────────────────────
# Usage: is_installed <command>
is_installed() { command -v "$1" &>/dev/null; }

# Usage: dnf_installed <package>
dnf_installed() { rpm -q "$1" &>/dev/null; }

# ── Phase 5: DNF system update ────────────────────────────────────────────────
phase "Phase 5 — System update"
sudo dnf upgrade --refresh -y
ok "System updated."
log "PHASE 5 DONE: system update"

# ── Phase 6: DNF dev toolchain ───────────────────────────────────────────────
phase "Phase 6 — Dev toolchain (dnf)"

DEV_PKGS=(
  gcc gcc-c++ make cmake clang
  gawk
  luarocks
  pipx
  rustup
  openssl openssl-devel
  docker
)

for pkg in "${DEV_PKGS[@]}"; do
  if dnf_installed "$pkg"; then
    skip "$pkg already installed."
  else
    sudo dnf install -y "$pkg"
    ok "$pkg installed."
  fi
done

log "PHASE 6 DONE: dev toolchain"

# ── Phase 7: DNF CLI tools ────────────────────────────────────────────────────
phase "Phase 7 — CLI tools (dnf)"

CLI_PKGS=(
  zsh stow
  ripgrep fzf fd zoxide
  tealdeer chafa eza bat
  btop jq wl-clipboard
  ImageMagick fastfetch
)

for pkg in "${CLI_PKGS[@]}"; do
  if dnf_installed "$pkg"; then
    skip "$pkg already installed."
  else
    sudo dnf install -y "$pkg"
    ok "$pkg installed."
  fi
done

# Neovim — install without weak deps to avoid pulling bundled nodejs/tree-sitter
if dnf_installed "neovim"; then
  skip "neovim already installed."
else
  sudo dnf install -y --setopt=install_weak_deps=False neovim
  sudo dnf install -y python3-neovim
  ok "neovim installed."
fi

# COPR: lazygit
if ! is_installed lazygit; then
  sudo dnf copr enable atim/lazygit -y
  sudo dnf install -y lazygit
  ok "lazygit installed."
else
  skip "lazygit already installed."
fi

# COPR: yazi
if ! is_installed yazi; then
  sudo dnf copr enable lihaohong/yazi -y
  sudo dnf install -y yazi
  ok "yazi installed."
else
  skip "yazi already installed."
fi

log "PHASE 7 DONE: CLI tools"

# ── Phase 8: Git configuration ────────────────────────────────────────────────
phase "Phase 8 — Git configuration"

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor nvim

# Bridge to Windows Git Credential Manager for HTTPS work repos
GCM_PATH="/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
if [[ -f "$GCM_PATH" ]]; then
  git config --global credential.helper "$GCM_PATH"
  ok "Git credential helper set to Windows GCM."
else
  warn "Windows GCM not found at expected path — credential helper not configured."
  warn "Set it manually later: git config --global credential.helper <path>"
fi

ok "Git globals configured."
log "PHASE 8 DONE: git configuration"

# ── Phase 9: Curl-based installers ───────────────────────────────────────────
phase "Phase 9 — Curl-based installers"

# Rustup (rustup is installed from dnf, just needs initialising)
if ! is_installed rustc; then
  rustup-init -y --no-modify-path
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
  cargo install cargo-update --locked
  ok "Rust toolchain initialised."
else
  skip "Rust already initialised."
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env" 2>/dev/null || true
fi

# Zinit
ZINIT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_DIR" ]]; then
  bash -c "$(curl --fail --show-error --silent --location \
    https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" \
    -- --no-preamble <<<"N"
  ok "Zinit installed."
else
  skip "Zinit already installed."
fi

# SDKMAN
if [[ ! -d "$HOME/.sdkman" ]]; then
  curl -s "https://get.sdkman.io" | bash
  ok "SDKMAN installed."
else
  skip "SDKMAN already installed."
fi

# Bun
if ! is_installed bun; then
  curl -fsSL https://bun.sh/install | bash
  ok "Bun installed."
else
  skip "Bun already installed."
fi

# pipx path
pipx ensurepath
if ! is_installed smassh; then
  pipx install smassh
  ok "smassh installed via pipx."
else
  skip "smassh already installed."
fi

log "PHASE 9 DONE: curl-based installers"

# ── Phase 10: Cargo builds ────────────────────────────────────────────────────
phase "Phase 10 — Cargo builds"

# Remove any dnf-installed tree-sitter-cli that neovim may have pulled in
if dnf_installed "tree-sitter-cli"; then
  sudo dnf remove -y tree-sitter-cli
  warn "Removed dnf tree-sitter-cli (replaced by cargo version)."
fi

# shellcheck source=/dev/null
source "$HOME/.cargo/env"

cargo_install() {
  local pkg="$1"
  if cargo install --list | rg -q "^$pkg "; then
    skip "$pkg already installed via cargo."
  else
    cargo install "$pkg" --locked
    ok "$pkg installed."
  fi
}

cargo_install starship
cargo_install tree-sitter-cli
cargo_install fnm

log "PHASE 10 DONE: cargo builds"

# ── Phase 11: Node.js ecosystem ───────────────────────────────────────────────
phase "Phase 11 — Node.js (fnm)"

# Eval fnm for this session so node/npm become available immediately
eval "$(fnm env --use-on-cd)"

if ! fnm list | rg -q "lts"; then
  fnm install --lts
  ok "Node LTS installed via fnm."
else
  skip "Node LTS already installed."
fi

fnm use lts-latest
eval "$(fnm env)"

corepack enable pnpm

ok "Node ecosystem ready."
log "PHASE 11 DONE: Node.js ecosystem"

# ── Phase 12: JVM ecosystem ───────────────────────────────────────────────────
phase "Phase 12 — JVM (SDKMAN)"

# Source SDKMAN for this session
export SDKMAN_DIR="$HOME/.sdkman"
# shellcheck disable=SC1091
source "$SDKMAN_DIR/bin/sdkman-init.sh"

sdk_install() {
  local pkg="$1"
  sdk install "$pkg"
  ok "$pkg installed."
}

sdk_install java
sdk_install maven
sdk_install gradle
sdk_install groovy
sdk_install kotlin

log "PHASE 12 DONE: JVM ecosystem"

# ── Phase 13: Change default shell ────────────────────────────────────────────
phase "Phase 13 — Default shell"

if [[ "$SHELL" != "/bin/zsh" ]]; then
  chsh -s /bin/zsh
  ok "Default shell changed to zsh."
else
  skip "Default shell is already zsh."
fi

log "PHASE 13 DONE: default shell"

# ── Phase 14: Stow dotfiles ───────────────────────────────────────────────────
phase "Phase 14 — Stow dotfiles"

cd "$DOTFILES_DIR"

stow_package() {
  local pkg="$1"
  # Stow exits non-zero if there are conflicts; check first
  if stow --simulate "$pkg" &>/dev/null; then
    stow "$pkg"
    ok "stow: $pkg"
  else
    warn "stow: $pkg has conflicts — skipping. Resolve manually and re-stow."
  fi
}

# Remove default .zshrc if it's a plain file (not a symlink we manage)
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  warn "Moved existing .zshrc to .zshrc.bak"
fi

stow_package zsh
stow_package starship
stow_package nvim
stow_package tealdeer

# shellcheck disable=SC2015
tldr --update && ok "tealdeer cache updated." || warn "tldr --update failed — run manually."

log "PHASE 14 DONE: stow"

# ── Write sentinel ────────────────────────────────────────────────────────────
echo "Bootstrap completed at $(date)" >"$SENTINEL"
log "Sentinel written. Bootstrap complete."

phase "All done"
echo ""
echo "  Restart WezTerm to pick up the new config."
echo ""
