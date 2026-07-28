# ----- Shell behaviour

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

# ----- History -----

HISTFILE="$XDG_STATE_HOME/zsh/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# ----- Autocompletion -----

autoload -Uz compinit
compinit -d "$XDG_STATE_HOME/zsh/zcompdump"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select
# Make completion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ----- Modular config files -----

source "$ZDOTDIR/settings/path.zsh"
source "$ZDOTDIR/settings/fzf.zsh"
source "$ZDOTDIR/settings/aliases.zsh"
source "$ZDOTDIR/settings/bindings.zsh"
source "$ZDOTDIR/settings/plugins.zsh"
source "$ZDOTDIR/settings/prompt.zsh"

# ----- Smart directory navigation -----

eval "$(zoxide init zsh)"

