# export TERM=xterm-256color

if [[ "$TERM" == "xterm-256color" && "$XDG_SESSION_TYPE" == "wayland" ]]; then
  export TERM=xterm-kitty
fi

alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias v="nvim"

eval "$(zoxide init zsh)"
