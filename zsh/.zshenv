# ----- XDG base directories -----
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ----- ZSH dotfile config -----
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# ----- Editor -----
export EDITOR="nvim"
export VISUAL="nvim"

# ----- GPG -----
export GPG_TTY=$(tty)

# ----- Pager -----
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# ----- PATH ----
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/homebrew/bin"
