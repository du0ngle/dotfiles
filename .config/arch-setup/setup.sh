#!/usr/bin/env bash
#
# Rebuilds this Arch setup on a fresh install.
#
# Run this AFTER a base Arch install that already boots and has a user account.
# It does not partition disks, install a bootloader, or create users.
#
# Usage:  ./setup.sh          run everything
#         ./setup.sh --list   show what it would do, change nothing
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# Cloned over HTTPS so a fresh machine with no SSH key yet can still get the
# dotfiles; the remote is switched to SSH right after, for pushing.
DOTFILES_REMOTE="git@github.com:du0ngle/dotfiles.git"
DOTFILES_CLONE_URL="https://github.com/du0ngle/dotfiles.git"

# .zshrc (from the dotfiles repo) puts these on PATH, but this script runs
# before that shell exists, so put them on PATH here too.
export PATH="$HOME/.local/bin:$HOME/.dotnet/tools:$PATH"

# --- Hardware specific: check these before running on a different machine ---
# atlantic-dkms   Aquantia/Marvell network driver, for this board's NIC
# nvidia-open     in packages.txt, along with intel-ucode and intel-media-driver
# nvidia.conf     the nvidia-drm modeset=1 drop-in written in step 3
# ---------------------------------------------------------------------------

SERVICES=(NetworkManager bluetooth docker sshd systemd-timesyncd tailscaled)

GIT_NAME="du0ngle"
GIT_EMAIL="lqduong81196@gmail.com"

# --- Pinned versions ------------------------------------------------------
# ARCH_SNAPSHOT freezes every pacman package at one date, via the Arch Linux
# Archive, so a rebuild installs the same versions this machine has today.
# It is applied only while this script runs; normal mirrors are restored at
# the end, so the machine still gets updates afterwards.
#
# This is the date of the last `pacman -Syu`, NOT the date this file was
# written. Verified: every package in packages.txt resolves in the 2026/08/22
# snapshot at exactly the installed version. Re-check after any full upgrade:
#   grep 'starting full system upgrade' /var/log/pacman.log | tail -1
ARCH_SNAPSHOT=2026/08/22

NPM_GLOBALS=(pyright@1.1.413 @openai/codex@0.130.0)
CLAUDE_VERSION=2.1.250
RUFF_VERSION=0.16.4
CSHARP_LS_VERSION=0.18.0
CODELLDB_VERSION=1.11.5
DEBUGPY_VERSION=1.8.21
ZSH_AUTOSUGGESTIONS_SHA=85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
FAST_SYNTAX_HIGHLIGHTING_SHA=dcee72bb99b422bb8e4510f5087af9c1721392e4

say() { printf '\n\033[36m==> %s\033[0m\n' "$*"; }

if [ "${1:-}" = "--list" ]; then
  echo "snapshot          : $ARCH_SNAPSHOT"
  echo "official packages : $(wc -l < "$HERE/packages.txt")"
  echo "AUR packages      : $(tr '\n' ' ' < "$HERE/aur.txt")"
  echo "services          : ${SERVICES[*]}"
  echo "npm globals       : ${NPM_GLOBALS[*]}"
  echo "claude code       : $CLAUDE_VERSION"
  echo "uv tools          : ruff==$RUFF_VERSION"
  echo "dotnet tools      : csharp-ls $CSHARP_LS_VERSION"
  echo "dotfiles          : $DOTFILES_REMOTE"
  exit 0
fi

# --- 1. Official packages, at the pinned snapshot -------------------------
MIRRORLIST=/etc/pacman.d/mirrorlist
restore_mirrors() {
  if [ -f "${MIRRORLIST}.prepin" ]; then
    say "Restoring normal mirrors"
    sudo mv "${MIRRORLIST}.prepin" "$MIRRORLIST"
    sudo pacman -Syy >/dev/null
  fi
}
trap restore_mirrors EXIT

say "Pinning pacman to the $ARCH_SNAPSHOT snapshot"
# Only back up if there is no backup yet, so a re-run after a hard kill does
# not overwrite the real mirrorlist with the archive one.
[ -f "${MIRRORLIST}.prepin" ] || sudo cp "$MIRRORLIST" "${MIRRORLIST}.prepin"
printf 'Server=https://archive.archlinux.org/repos/%s/$repo/os/$arch\n' \
  "$ARCH_SNAPSHOT" | sudo tee "$MIRRORLIST" >/dev/null

say "Installing $(wc -l < "$HERE/packages.txt") packages from the official repos"
# -Syuu allows downgrades, since a fresh install may be newer than the snapshot.
sudo pacman -Syuu --needed --noconfirm - < "$HERE/packages.txt"

# --- 2. yay, then the AUR packages ---------------------------------------
if ! command -v yay >/dev/null; then
  say "Building yay"
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

say "Installing AUR packages"
# shellcheck disable=SC2046
yay -S --needed --noconfirm $(grep -v '^yay$' "$HERE/aur.txt" | tr '\n' ' ')

# --- 3. Kernel module options --------------------------------------------
# Hyprland needs nvidia DRM kernel mode setting. mkinitcpio's kms hook loads
# the nvidia modules early, so the drop-in has to be in the initramfs too.
say "nvidia-drm modeset"
NVIDIA_CONF=/etc/modprobe.d/nvidia.conf
if [ "$(cat "$NVIDIA_CONF" 2>/dev/null)" != "options nvidia-drm modeset=1" ]; then
  echo 'options nvidia-drm modeset=1' | sudo tee "$NVIDIA_CONF" >/dev/null
  sudo mkinitcpio -P
fi

# --- 4. Services ----------------------------------------------------------
say "Enabling services"
sudo systemctl enable --now "${SERVICES[@]}"

say "Adding $USER to the docker group"
sudo usermod -aG docker "$USER"   # takes effect after the next login

# --- 5. Git identity ------------------------------------------------------
# Not in the dotfiles repo: ~/.gitconfig holds the identity and the global
# ignore file keeps per-project Claude settings out of every repo.
say "Git identity"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global core.editor nvim

mkdir -p "$HOME/.config/git"
grep -qxF '**/.claude/settings.local.json' "$HOME/.config/git/ignore" 2>/dev/null \
  || echo '**/.claude/settings.local.json' >> "$HOME/.config/git/ignore"

# --- 6. Dotfiles ----------------------------------------------------------
# Declarative on purpose: assert the end state rather than branching on how we
# got here. Each step is a no-op when already satisfied, so this behaves the
# same whether the repo was cloned by this script, cloned by hand to get hold
# of this script, or sparse-checked-out with only the bootstrapper.
dotgit() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }

if [ ! -d "$HOME/.dotfiles" ]; then
  say "Cloning dotfiles"
  git clone --bare "$DOTFILES_CLONE_URL" "$HOME/.dotfiles"
fi

say "Checking out dotfiles"
# Widen a bootstrap sparse-checkout to the whole tree. `config --unset` is not
# enough: it leaves the skip-worktree bits set in the index, so checkout would
# not re-materialise the excluded files. `sparse-checkout disable` clears them.
# No-op when sparse checkout was never enabled.
dotgit sparse-checkout disable 2>/dev/null || true

# $HOME may already hold a file this repo tracks -- zsh writes a .zshrc on
# first run, a GTK app writes .config/gtk-3.0/settings.ini. checkout refuses to
# clobber those and exits 1, which under `set -e` would kill the script here.
# Move them aside and retry instead.
if ! dotgit checkout 2>/dev/null; then
  conflicts="$(dotgit checkout 2>&1 || true)"
  conflicts="$(printf '%s\n' "$conflicts" | awk '/^\t/ {print $1}')"
  backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
  say "Moving pre-existing files aside to $backup"
  printf '%s\n' "$conflicts" | while read -r f; do
    [ -n "$f" ] || continue
    mkdir -p "$backup/$(dirname "$f")"
    mv "$HOME/$f" "$backup/$f"
    echo "  $f"
  done
  dotgit checkout
fi

dotgit config status.showUntrackedFiles no
dotgit remote set-url origin "$DOTFILES_REMOTE"

# --- 7. Things pacman does not cover -------------------------------------
say "zsh plugins"
mkdir -p "$HOME/.zsh/plugins"
clone_pinned() {  # repo url, target dir, commit
  [ -d "$2" ] || git clone "$1" "$2"
  # Re-apply the pin even when the clone already exists. The earlier version
  # returned early if the directory was present, so a clone made before the
  # pin was chosen silently stayed on whatever commit it happened to have.
  if [ "$(git -C "$2" rev-parse HEAD 2>/dev/null)" != "$3" ]; then
    git -C "$2" fetch --quiet origin
    git -C "$2" checkout -q "$3"
  fi
}
clone_pinned https://github.com/zsh-users/zsh-autosuggestions \
  "$HOME/.zsh/plugins/zsh-autosuggestions" "$ZSH_AUTOSUGGESTIONS_SHA"
clone_pinned https://github.com/zdharma-continuum/fast-syntax-highlighting \
  "$HOME/.zsh/plugins/fast-syntax-highlighting" "$FAST_SYNTAX_HIGHLIGHTING_SHA"

say "npm globals"
# npm globals go under ~/.local, not /usr, so no sudo here. ~/.npmrc is what
# makes `npm i -g` land there, and it is not in the dotfiles repo.
grep -qxF "prefix=$HOME/.local" "$HOME/.npmrc" 2>/dev/null \
  || echo "prefix=$HOME/.local" >> "$HOME/.npmrc"
npm install -g "${NPM_GLOBALS[@]}"

say "Claude Code"
# Standalone native install under ~/.local/share/claude, symlinked into
# ~/.local/bin. Not an npm package. It self-updates after this pinned install.
if [ "$(claude --version 2>/dev/null | cut -d' ' -f1)" != "$CLAUDE_VERSION" ]; then
  curl -fsSL https://claude.ai/install.sh | bash -s "$CLAUDE_VERSION"
fi

say "ruff (nvim's lsp/ruff.lua points at this)"
[ "$(ruff --version 2>/dev/null | cut -d' ' -f2)" = "$RUFF_VERSION" ] \
  || uv tool install --force "ruff==${RUFF_VERSION}"

say "csharp-ls (nvim's lsp/csharp.lua points at this)"
dotnet tool list --global | grep -q '^csharp-ls ' \
  || dotnet tool install --global csharp-ls --version "$CSHARP_LS_VERSION"

say "debugpy venv (nvim-dap-python points at this)"
[ -x "$HOME/.virtualenvs/debugpy/bin/python" ] || {
  uv venv "$HOME/.virtualenvs/debugpy"
  VIRTUAL_ENV="$HOME/.virtualenvs/debugpy" uv pip install "debugpy==${DEBUGPY_VERSION}"
}

say "codelldb (nvim-dap points at this)"
[ -x "$HOME/tools/codelldb/extension/adapter/codelldb" ] || {
  mkdir -p "$HOME/tools/codelldb"
  curl -fsSL "https://github.com/vadimcn/codelldb/releases/download/v${CODELLDB_VERSION}/codelldb-linux-x64.vsix" \
    -o /tmp/codelldb.vsix
  bsdtar -xf /tmp/codelldb.vsix -C "$HOME/tools/codelldb"
  rm /tmp/codelldb.vsix
  chmod +x "$HOME/tools/codelldb/extension/adapter/codelldb"
}

say "Making zsh the login shell"
[ "$SHELL" = /usr/bin/zsh ] || chsh -s /usr/bin/zsh

cat <<'DONE'

Done. Still to do by hand:

  - log out and back in    (docker group, and the zsh login shell)
  - ssh-keygen and add the key to GitHub
  - open nvim once, let Lazy install the plugins
  - tailscale up
  - claude          (log in on first run)

Everything above is pinned to the versions this machine had when the script
was written. To move forward later:  sudo pacman -Syu
DONE
