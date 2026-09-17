typeset -U path
path=("$HOME/.local/bin" /opt/homebrew/bin /opt/homebrew/sbin $path)

export EDITOR='nvim'
export VISUAL='nvim'
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_REDUCE_BLANKS INC_APPEND_HISTORY
unsetopt NOMATCH

autoload -Uz compinit
for dump in "${ZDOTDIR:-$HOME}/.zcompdump"(N.mh+24); do
  compinit
  break
done
compinit -C
bindkey -e
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[3;5~' kill-word

if (( $+commands[fzf] )); then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS='--height 45% --layout=reverse --border --inline-info'
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --exclude .git'
  fi
fi

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

rationalise-dot() {
  if [[ $LBUFFER == *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N rationalise-dot
bindkey '.' rationalise-dot
bindkey -M isearch '.' self-insert

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --git --group-directories-first'
  alias tree='eza --icons=auto --git --tree --group-directories-first'
fi

if (( $+commands[dust] )); then
  alias du='dust'
fi

alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias rm='rm -I'
alias speedtest='networkQuality'
alias ports='lsof -iTCP -sTCP:LISTEN -n -P'

mkcd() {
  mkdir -p "$1" && cd "$1"
}

extract() {
  if (( $# == 0 )); then
    echo "Usage: extract <file...>" >&2
    return 1
  fi
  for file in "$@"; do
    if [[ ! -f "$file" ]]; then
      echo "extract: '$file' is not a valid file" >&2
      continue
    fi
    case "${file:l}" in
      *.tar.bz2|*.tbz2|*.tar.gz|*.tgz|*.tar.xz|*.txz|*.tar.zst|*.tar)
        tar -xf "$file"
        ;;
      *.bz2)
        bunzip2 -k "$file"
        ;;
      *.gz)
        gunzip -k "$file"
        ;;
      *.xz)
        unxz -k "$file"
        ;;
      *.zip)
        unzip -q "$file"
        ;;
      *.7z|*.rar)
        if (( $+commands[7zz] )); then
          7zz x "$file"
        elif (( $+commands[7z] )); then
          7z x "$file"
        elif (( $+commands[7za] )); then
          7za x "$file"
        elif (( $+commands[unrar] )); then
          unrar x "$file"
        else
          echo "extract: '7z' or 'unrar' is required to extract '$file'" >&2
        fi
        ;;
      *)
        echo "extract: '$file' cannot be extracted" >&2
        ;;
    esac
  done
}

alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline'
alias gll='git log'
alias gpl='git pull'
alias gf='git fetch'

if [[ -r /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]]; then
  source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
  antidote load "${${(%):-%x}:A:h}/.zsh_plugins.txt"
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  [[ -n "$terminfo[kcuu1]" ]] && bindkey "$terminfo[kcuu1]" history-substring-search-up
  [[ -n "$terminfo[kcud1]" ]] && bindkey "$terminfo[kcud1]" history-substring-search-down
fi

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
