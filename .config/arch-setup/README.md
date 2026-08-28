# arch-setup

Rebuilds my desktop on a fresh Arch install.

Run this once Arch boots, has a user account with sudo, and is online. It does
not partition disks, install a bootloader, create users, or set up networking.
`PACKAGES.md` says why each package is on the list.

## 1. Install git

```bash
sudo pacman -S git
```

## 2. Clone the dotfiles repo

The bootstrapper lives inside here.

```bash
git clone --bare https://github.com/du0ngle/dotfiles.git ~/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout
```

HTTPS because there is no SSH key yet. `setup.sh` switches the remote to SSH.

## 3. Run it

```bash
~/.config/arch-setup/setup.sh
```

About 15 minutes. `--list` shows what it would do and changes nothing.

Packages come from `packages.txt` at a pinned snapshot; mirrors are restored
afterwards.

## 4. Finish by hand

```bash
# log out and back in first, for the docker group and the zsh shell
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub        # paste into github.com/settings/keys
sudo tailscale up
nvim                             # let Lazy install the plugins
claude                           # log in
```

## Hardware

Check these on a different machine:

- `atlantic-dkms` — Aquantia NIC on this board
- `nvidia-open`, `nvidia-utils`, `linux-firmware-nvidia` — nvidia dGPU
- `intel-ucode`, `intel-media-driver`, `vulkan-intel` — Intel CPU and iGPU

## Keeping it current

After installing or removing packages:

```bash
pacman -Qqen > ~/.config/arch-setup/packages.txt
```

After `pacman -Syu`, set `ARCH_SNAPSHOT` in `setup.sh` to the upgrade date:

```bash
grep 'starting full system upgrade' /var/log/pacman.log | tail -1
```

`dev-environment/Dockerfile` has the same date. Keep them equal.
