# Package reference

Why each package in `packages.txt` and `aur.txt` is installed. What they are is
left to `pacman -Qi`.

`packages.txt` matches `pacman -Qqen` exactly (69 entries). Packages installed
only as dependencies are left out. Scope is this desktop; the laptop shares the
dotfiles repo but not this list.

## Base and boot

| Package | Reason |
|---|---|
| `base`, `base-devel` | Minimal Arch set, plus the build tools `makepkg` needs |
| `sudo` | `setup.sh` and daily admin |
| `grub`, `efibootmgr` | Bootloader and its EFI boot entries |
| `os-prober` | Finds the Windows install. The `reboot-windows` alias uses the `osprober-efi-40C7-5064` entry |
| `intel-ucode` | CPU microcode, loaded by the `microcode` mkinitcpio hook |

## Kernels and firmware

| Package | Reason |
|---|---|
| `linux` | Daily driver |
| `linux-lts` | Fallback when a mainline bump breaks nvidia or the NIC |
| `linux-headers`, `linux-lts-headers` | DKMS builds `atlantic` against both kernels |
| `linux-firmware`, `linux-firmware-nvidia` | Device firmware; `nvidia-open` needs the nvidia set |
| `sof-firmware` | Onboard audio DSP |

## Graphics

Intel iGPU and nvidia dGPU, so both stacks are present.

| Package | Reason |
|---|---|
| `nvidia-open`, `nvidia-utils` | The dGPU, and the EGL/Vulkan/VA-API libraries Hyprland renders through. Keep `nvidia-utils` listed: it satisfies `opengl-driver`, which `mesa` also provides |
| `intel-media-driver`, `vulkan-intel` | VA-API decode and Vulkan on the iGPU |
| `mesa-utils` | Diagnosing which GPU a program landed on |

`setup.sh` writes `/etc/modprobe.d/nvidia.conf` with `nvidia-drm modeset=1`,
which Hyprland needs on nvidia, then runs `mkinitcpio -P` so the drop-in lands
in the initramfs where the `kms` hook reads it.

## Desktop (Hyprland / Wayland)

| Package | Reason |
|---|---|
| `hyprland` | The compositor |
| `waybar` | Status bar, `exec-once`. Pulls in `playerctl` for the media keys |
| `wofi` | Launcher, SUPER+TAB |
| `swaybg` | Wallpaper, `exec-once` |
| `kitty` | Terminal, SUPER+T |
| `thunar` | File manager, SUPER+E |
| `ttf-jetbrains-mono-nerd` | Named in `waybar/style.css`; kitty inherits it as default monospace |
| `wl-clipboard`, `xclip` | Clipboard for Wayland and XWayland programs |
| `wayland-utils` | Checking which protocols the compositor exposes |

The `XF86MonBrightness` bindings in `hyprland.conf` call `brightnessctl`, which
is installed on the laptop only. They do nothing here; `DP-3`'s brightness is on
the monitor itself.

## Audio

| Package | Reason |
|---|---|
| `pipewire-pulse`, `pipewire-alsa`, `pipewire-jack` | Audio server, plus ALSA and JACK compatibility. Keep `pipewire-jack` listed: it satisfies `jack`, which `jack2` also provides |
| `alsa-utils` | `alsamixer` when nothing comes out |

These pull in `wireplumber`, which provides the `wpctl` every volume binding calls.

## Peripherals

| Package | Reason |
|---|---|
| `bluez`, `bluez-utils` | `bluetooth.service` is enabled; `bluetoothctl` pairs from the terminal |
| `usbutils` | `lsusb` |
| `libwacom` | No tablet attached; it comes via `hyprland` → `libinput` regardless |

## Networking

| Package | Reason |
|---|---|
| `atlantic-dkms` *(AUR)* | This board's ethernet. `enp3s0` binds to the `atlantic` driver. First thing to reconsider on other hardware |
| `networkmanager` | Manages `enp3s0` and `wlan0` |
| `iwd` | Wifi backend. `wlan0` is down, ethernet is the live link; kept as a fallback |
| `openssh` | `sshd` for remote login, and git over SSH |
| `tailscale` | Mesh VPN |
| `bind` | `dig` and `nslookup`. The daemon is not enabled |
| `ethtool`, `wakeonlan` | Inspecting the link, arming and sending Wake-on-LAN |
| `wget` | Scripts and one-off fetches |

## Shell and terminal

| Package | Reason |
|---|---|
| `zsh` | Login shell, set by `chsh` at the end of `setup.sh` |
| `tmux` | Long-running sessions over ssh |
| `fzf` | Backs the `fzfcd` function in `.zshrc` |
| `zoxide` | `eval "$(zoxide init zsh)"` in `.zshrc` |
| `ripgrep` | Used directly, and by telescope.nvim |
| `less` | Pager for git and man |
| `fastfetch` | Banner at the top of every shell |
| `7zip` | General extraction |

`setup.sh` also clones `zsh-autosuggestions` and `fast-syntax-highlighting` at
pinned commits.

## Editor and toolchains

| Package | Reason |
|---|---|
| `neovim` | Config in `.config/nvim`, plugins pinned in `lazy-lock.json` |
| `git`, `git-filter-repo` | Version control, plus history rewriting |
| `clang` | Compiler and `clangd`, for `lsp/clangd.lua` |
| `dotnet-sdk` | C# projects, and the runtime `csharp-ls` needs |
| `nodejs`, `npm` | Runs `pyright` and `codex`. Prefix is `~/.local` via `~/.npmrc`, so no root |
| `uv` | Creates the debugpy venv and installs `ruff`; the only Python tooling |
| `docker`, `docker-buildx` | `docker.service` is enabled, user is in the `docker` group |

`go` is not listed; it arrives as a build dependency of `yay`.

### Outside pacman

Pinned in `setup.sh`. Nvim references several by absolute path.

| Tool | Version | Source | Used by |
|---|---|---|---|
| Claude Code | 2.1.250 | native installer | CLI; self-updates afterwards |
| `pyright` | 1.1.413 | npm | `lsp/python.lua` |
| `ruff` | 0.16.4 | `uv tool` | `lsp/ruff.lua` |
| `csharp-ls` | 0.18.0 | `dotnet tool` | `lsp/csharp.lua` |
| `codelldb` | 1.11.5 | vsix | `plugins/dap.lua:19` |
| `debugpy` | 1.8.21 | uv venv | `dap.lua:46` |
| `@openai/codex` | 0.130.0 | npm | CLI |

## Filesystems, apps, package management

| Package | Reason |
|---|---|
| `dosfstools`, `mtools` | The EFI system partition; grub uses mtools on UEFI |
| `ntfs-3g` | Reading the Windows partition |
| `firefox` | Browser |
| `spotify-launcher` | Fetches Spotify's own client, packaged for Arch |
| `yay` *(AUR)* | Installs `atlantic-dkms`. `setup.sh` bootstraps it from source |
| `reflector` | Ranks mirrors. The timer is disabled; `setup.sh` writes the mirrorlist itself |

## Snapshot

`setup.sh` pins every package to the 2026/08/22 Arch Archive snapshot, the date
of the last full upgrade. Re-derive it after any `pacman -Syu`:

```
grep 'starting full system upgrade' /var/log/pacman.log | tail -1
```

The same date is in `dev-environment/Dockerfile`; keep the two equal.
