# ----- LS -----

# Better ls
alias ls='eza --icons'
# Detailed listing
alias ll='eza -lh --icons --git'
# Detailed listing including hidden files
alias la='eza -lah --icons --git'
# Tree view
alias tree='eza --tree --icons'
# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# ----- CAT -----

# Better cat
alias cat='bat'

# ----- GIT -----

# Get the default branch name from common branch names or fallback to remote HEAD
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return 
  local remote ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done
  
  # Fallback: try to get the default branch from remote HEAD symbolic refs
  for remote in origin upstream; do
    ref=$(command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
    if [[ $ref == $remote/* ]]; then
      echo ${ref#"$remote/"}; return 0
    fi
  done

  # If no main branch was found, fall back to master but return error
  echo master
  return 1
}

alias gst='git status'
alias gph='git push'
alias gpl='git pull'
alias gpr='git pull --rebase'

alias gsw='git switch'
alias gswc='git switch --create'
alias gswm='git switch $(git_main_branch)'

alias gstall='git stash --all'
alias gstapp='git stash apply'
alias gstpop='git stash pop'

# ----- Docker -----

alias dcu="docker compose up"
alias dcb="docker compose build"
alias dcr="docker compose run --rm"

# ----- Core utilities -----

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# ----- Navigation -----

# -- prevents - being parsed as a flag; cd - jumps to previous directory
alias -- -='cd -' 

lf() { # zsh follow lf navigation
    tmp=$(mktemp)
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

