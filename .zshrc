# ------------ Initialization ------------ 
if [[ "$TERM" == "xterm-256color" && "$XDG_SESSION_TYPE" == "wayland" ]]; then
  export TERM=xterm-kitty
fi

PROMPT='%F{#c4a7e7}%n@%m%f %F{#ebbcba}%~%f %F{105}>%f '

fastfetch

# ------------ Alias ------------ 
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias v="nvim"

# ------------ Functions ------------ 
fzfcd() {
  local file
  file=$(fzf)
  if [[ -n "$file" ]]; then
    cd "$(dirname "$file")"
  fi
}

# ------------ Plugins------------ 
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

eval "$(zoxide init zsh)"
