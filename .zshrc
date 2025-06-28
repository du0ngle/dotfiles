if [[ "$TERM" == "xterm-256color" && "$XDG_SESSION_TYPE" == "wayland" ]]; then
  export TERM=xterm-kitty
fi

PROMPT='%F{green}%n@%m%f %F{blue}%~%f %F{105}>%f '

alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias v="nvim"

fzfcd() {
  local file
  file=$(fzf)
  if [[ -n "$file" ]]; then
    cd "$(dirname "$file")"
  fi
}


# zsh-autosuggestions
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# fast-syntax-highlighting
source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh


eval "$(zoxide init zsh)"
