#!/usr/bin/env bash
#
# Claude Code statusLine script.
#
# Mirrors the visual style of the Starship prompt defined in
# ~/.config/starship.toml (Catppuccin Mocha color blocks), left-aligned
# with no separators between segments:
#   [ dir ][ languages ][ git branch/status ][ ctx/effort ]
#
# Reads the Claude Code status JSON from stdin.

set -u

input=$(cat)

json() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

cwd=$(json '.workspace.current_dir // .cwd')
[[ -z "$cwd" || "$cwd" == "null" ]] && cwd="$PWD"
model_name=$(json '.model.display_name // empty')
used_pct=$(json '.context_window.used_percentage // empty')
effort_level=$(json '.effort.level // empty')

# ----- Catppuccin Mocha palette (truecolor RGB) -----
CRUST="17;17;27"
RED="243;139;168"
GREEN="166;227;161"
YELLOW="249;226;175"
SAPPHIRE="116;199;236"

RESET=$'\033[0m'

fg() { printf '\033[38;2;%sm' "$1"; }
bg() { printf '\033[48;2;%sm' "$1"; }

# ----- Nerd Font glyphs (as \u/\U escapes - literal glyphs don't survive
# editor round-trips reliably, matching the exact codepoints starship.toml
# uses for each module/substitution) -----
DIR_ICON="󰘧"
MODEL_ICON=""
DESKTOP_ICON="󰧨"
DOCUMENTS_ICON="󰈙"
DOWNLOADS_ICON=""
MUSIC_ICON="󰝚"
PICTURES_ICON=""
PROJECTS_ICON="󰲋"
GIT_ICON=""
C_ICON=""
RUST_ICON=""
GOLANG_ICON=""
NODEJS_ICON=""
BUN_ICON=""
PHP_ICON=""
JAVA_ICON=""
KOTLIN_ICON=""
HASKELL_ICON=""
PYTHON_ICON=""

# ---------------------------------------------------------------------------
# Directory segment (bg:red fg:crust, truncation_length=4, home -> ~,
# folder-name substitutions, truncation_symbol="…/")
# ---------------------------------------------------------------------------
build_directory() {
  local p="$1" home="$HOME" prefix=""

  if [[ "$p" == "$home" ]]; then
    p="~"
  elif [[ "$p" == "$home"/* ]]; then
    p="~/${p#"$home"/}"
  fi

  if [[ "$p" == /* ]]; then
    prefix="/"
    p="${p#/}"
  fi

  local -a comps
  IFS='/' read -r -a comps <<< "$p"

  local i
  for i in "${!comps[@]}"; do
    case "${comps[$i]}" in
      Desktop)   comps[$i]="${DESKTOP_ICON} " ;;
      Documents) comps[$i]="${DOCUMENTS_ICON} " ;;
      Downloads) comps[$i]="${DOWNLOADS_ICON} " ;;
      Music)     comps[$i]="${MUSIC_ICON} " ;;
      Pictures)  comps[$i]="${PICTURES_ICON} " ;;
      Projects)  comps[$i]="${PROJECTS_ICON} " ;;
    esac
  done

  local n=${#comps[@]}
  local out
  if (( n > 4 )); then
    comps=("${comps[@]: -4}")
    out=$(IFS=/; echo "${comps[*]}")
    printf '…/%s' "$out"
  else
    out=$(IFS=/; echo "${comps[*]}")
    printf '%s%s' "$prefix" "$out"
  fi
}

dir_display=$(build_directory "$cwd")

# ---------------------------------------------------------------------------
# Language / toolchain segments (bg:green fg:crust) - only shown when a
# matching project marker file is found in the current directory, mirroring
# starship's per-language modules ($c $rust $golang $nodejs $bun $php $java
# $kotlin $haskell $python).
# ---------------------------------------------------------------------------
has() { compgen -G "$cwd/$1" > /dev/null 2>&1; }

lang_segments=()

has "*.c" || has "Makefile" && {
  v=$(cc --version 2>/dev/null | head -1 | awk '{print $NF}')
  [[ -n "$v" ]] && lang_segments+=("${C_ICON} ${v}")
}

if has "Cargo.toml"; then
  v=$(rustc --version 2>/dev/null | awk '{print $2}')
  [[ -n "$v" ]] && lang_segments+=("${RUST_ICON} ${v}")
fi

if has "go.mod"; then
  v=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
  [[ -n "$v" ]] && lang_segments+=("${GOLANG_ICON} ${v}")
fi

if has "package.json"; then
  v=$(node --version 2>/dev/null | tr -d 'v')
  [[ -n "$v" ]] && lang_segments+=("${NODEJS_ICON} ${v}")
fi

if has "bun.lockb" || has "bunfig.toml"; then
  v=$(bun --version 2>/dev/null)
  [[ -n "$v" ]] && lang_segments+=("${BUN_ICON} ${v}")
fi

if has "composer.json"; then
  v=$(php --version 2>/dev/null | head -1 | awk '{print $2}')
  [[ -n "$v" ]] && lang_segments+=("${PHP_ICON} ${v}")
fi

if has "pom.xml" || has "build.gradle"; then
  v=$(java -version 2>&1 | head -1 | awk -F'"' '{print $2}')
  [[ -n "$v" ]] && lang_segments+=("${JAVA_ICON} ${v}")
fi

if has "build.gradle.kts" || has "*.kt"; then
  v=$(kotlin -version 2>&1 | awk '{print $3}')
  [[ -n "$v" ]] && lang_segments+=("${KOTLIN_ICON} ${v}")
fi

if has "*.cabal" || has "stack.yaml"; then
  v=$(ghc --numeric-version 2>/dev/null)
  [[ -n "$v" ]] && lang_segments+=("${HASKELL_ICON} ${v}")
fi

if has "requirements.txt" || has "pyproject.toml" || has "setup.py"; then
  v=$(python3 --version 2>/dev/null | awk '{print $2}')
  [[ -n "$v" ]] && lang_segments+=("${PYTHON_ICON} ${v}")
fi

# ---------------------------------------------------------------------------
# Git segment (bg:yellow fg:crust) - locks skipped for read-only queries
# ---------------------------------------------------------------------------
branch=""
git_status_str=""
if git --no-optional-locks -C "$cwd" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && branch=$(git --no-optional-locks -C "$cwd" rev-parse --short HEAD 2>/dev/null)

  dirty=$(git --no-optional-locks -C "$cwd" status --porcelain 2>/dev/null)
  [[ -n "$dirty" ]] && git_status_str+="✗"

  upstream=$(git --no-optional-locks -C "$cwd" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
  if [[ -n "$upstream" ]]; then
    counts=$(git --no-optional-locks -C "$cwd" rev-list --left-right --count "HEAD...${upstream}" 2>/dev/null)
    ahead=$(awk '{print $1}' <<< "$counts")
    behind=$(awk '{print $2}' <<< "$counts")
    [[ "${ahead:-0}" -gt 0 ]] && git_status_str+=" ⇡${ahead}"
    [[ "${behind:-0}" -gt 0 ]] && git_status_str+=" ⇣${behind}"
  fi
fi

# ---------------------------------------------------------------------------
# Render - segments are collected as (color, text) pairs, then joined with
# solid triangle separators (nerd font powerline glyph, matches starship).
# ---------------------------------------------------------------------------
ARROW=$''

seg_colors=()
seg_texts=()

seg_colors+=("$RED"); seg_texts+=(" ${DIR_ICON} ${dir_display} ")

if (( ${#lang_segments[@]} > 0 )); then
  lang_text=""
  for seg in "${lang_segments[@]}"; do
    lang_text+=" ${seg} "
  done
  seg_colors+=("$GREEN"); seg_texts+=("$lang_text")
fi

if [[ -n "$branch" ]]; then
  git_text=" ${GIT_ICON}  ${branch}"
  [[ -n "$git_status_str" ]] && git_text+=" ${git_status_str}"
  git_text+=" "
  seg_colors+=("$YELLOW"); seg_texts+=("$git_text")
fi

ctx_text=" ${MODEL_ICON}  "
[[ -n "$model_name" ]] && ctx_text+="${model_name}"
[[ -n "$effort_level" && "$effort_level" != "null" ]] && ctx_text+=" · ${effort_level}"
if [[ -n "$used_pct" && "$used_pct" != "null" ]]; then
  pct=$(printf '%.0f' "$used_pct" 2>/dev/null || echo "$used_pct")
  ctx_text+=" · ctx ${pct}%"
fi
ctx_text+=" "
seg_colors+=("$SAPPHIRE"); seg_texts+=("$ctx_text")

content=""
for i in "${!seg_colors[@]}"; do
  if (( i > 0 )); then
    content+="$(bg "${seg_colors[$i]}")$(fg "${seg_colors[$((i - 1))]}")${ARROW}${RESET}"
  fi
  content+="$(bg "${seg_colors[$i]}")$(fg "$CRUST")${seg_texts[$i]}${RESET}"
done
last_i=$(( ${#seg_colors[@]} - 1 ))
content+="$(fg "${seg_colors[$last_i]}")${ARROW}${RESET}"

printf '%s\n' "$content"
