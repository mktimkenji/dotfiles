# ==========================================
# 1. PATH & ENV VARIABLES
# ==========================================
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export MANPAGER="nvim +Man!"
export MANWIDTH=999

# ==========================================
# 2. ZSH OPTIONS
# ==========================================
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt AUTO_CD
setopt CORRECT
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT
setopt NO_BEEP

HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000

# ==========================================
# 3. COMPLETIONS
# ==========================================
autoload -Uz compinit
#  INFO: only regenerate .zcompdump once a day
if [[ -n "${HOME}/.zcompdump"(Nm-1) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# ==========================================
# 4. ZINIT & PLUGINS
# ==========================================
#  INFO: zinit needs to be installed via official script
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode
zinit light zdharma-continuum/fast-syntax-highlighting

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --icons --color=always $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --icons --color=always $realpath 2>/dev/null'

# ==========================================
# 5. KEY BINDINGS & VI MODE
# ==========================================
function zvm_after_init() {
  eval "$(fzf --zsh)" # Ctrl+R (history), Ctrl+T (files), Alt+C (cd)

  bindkey '^[[A' history-search-backward  # Up arrow
  bindkey '^[[B' history-search-forward   # Down arrow
  bindkey '^[[1;5C' forward-word          # Ctrl+Right
  bindkey '^[[1;5D' backward-word         # Ctrl+Left
  bindkey '^[[3~' delete-char             # Delete key
  bindkey '^A' beginning-of-line          # Ctrl+A
  bindkey '^E' end-of-line                # Ctrl+E
}

# Start in insert mode by default
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

# Cursor style per mode
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

# ==========================================
# 6. INITIALIZE MODERN CLI TOOLS
# ==========================================
source "$HOME/.cargo/env"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# ==========================================
# 7. ALIASES — NAVIGATION
# ==========================================
alias cd="z"
alias cdi="zi"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ==========================================
# 8. ALIASES — FILE LISTING
# ==========================================
alias ls="eza --icons"
alias la="eza -a --icons" # all including dotfiles
alias ll="eza -lah --icons --git"
alias lt="eza --tree --icons --level=2"
alias tree="eza -a --tree --icons --level=5"

# ==========================================
# 9. ALIASES — SYSTEM
# ==========================================
alias df="df -h"
alias free="free -h"
alias fd="fd --hidden"
alias mkdir="mkdir -p"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias rg="rg --color=auto"
alias grep="grep --color=auto"

# ==========================================
# 10. ALIASES — GIT
# ==========================================
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gpu="git push -u origin HEAD"
alias gpl="git pull"
alias gl="git log --oneline --graph --decorate --all"
alias gd="git diff"
alias gco="git checkout"
alias gn="git checkout -b"
alias gb="git branch"
alias gbd='git branch | grep -vE "^\*?\s*(main|master)$" | xargs git branch -D'
alias gst="git stash"

# ==========================================
# 11. ALIASES — EDITOR
# ==========================================
alias nv="nvim"
alias dot="nvim ~/dotfiles"
alias zshrc="nvim ~/.zshrc"
alias reload="source ~/.zshrc"

# ==========================================
# 12. FUNCTIONS
# ==========================================
#  NOTE: mkcd, make a directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

#  NOTE: extract, universal archive extractor
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive>"
    return 1
  fi

  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2|*.tbz2) tar xjf "$1" ;;
      *.tar.gz|*.tgz)   tar xzf "$1" ;;
      *.tar.xz|*.txz)   tar xJf "$1" ;;
      *.zip)            unzip "$1" ;;
      *.gz)             gunzip "$1" ;;
      *.tar)            tar xf "$1" ;;
      *.7z)             7z x "$1" ;;
      *.rar)            unrar x "$1" ;;
      *)
        echo "'$1' cannot be extracted"
        return 1
        ;;
    esac
  else
    echo "'$1' is not a valid file"
    return 1
  fi
}

# ==========================================
# 13. TOOLING
# ==========================================
# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# SDKMAN
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# fnm
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# pnpm
if [[ -d "$HOME/.local/share/pnpm" ]]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  path=("$PNPM_HOME" $path)
fi

# Run fastfetch as initial command
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi
