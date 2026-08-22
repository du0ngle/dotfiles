# ------------ Initialization ------------ 
if [[ "$TERM" == "xterm-256color" && "$XDG_SESSION_TYPE" == "wayland" ]]; then
  export TERM=xterm-kitty
fi

PROMPT='%F{#c4a7e7}%n@%m%f %F{#ebbcba}%~%f %F{105}>%f '

fastfetch --logo arch \
  --logo-color-1 "#ebbcba" \
  --logo-color-2 "#c4a7e7"

# ------------ Alias ------------ 
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias dfs="git --git-dir=$HOME/.dotfiles --work-tree=$HOME status --short --untracked-files=no"
alias dfd="git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff"
alias v="nvim"
alias reboot-windows='sudo grub-reboot osprober-efi-40C7-5064 && sudo reboot'

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

# ------------ LSP ------------ 
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$HOME/.local/bin:$PATH"
