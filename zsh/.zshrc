export EDITOR='nvim'
export VISUAL='nvim'

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_REDUCE_BLANKS

autoload -Uz compinit
compinit
bindkey -e

if (( $+commands[fzf] )); then
  source <(fzf --zsh)
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

alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias rm='rm -I'

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
fi
