# Package reference

Why each package in `packages.txt` and `aur.txt` is installed. The what is left
to `pacman -Qi`; this file records the reason, which pacman cannot know.

**Scope is this desktop.** A second Arch machine (laptop) checks out the
same dotfiles repo but is deliberately not covered here. Items marked *laptop*
are live there and inert on this machine.

`packages.txt` lists **every explicitly installed package** and matches
`pacman -Qqen` exactly — 69 entries. That invariant is checkable in one
command, and it is what makes the file trustworthy.

Listing everything rather than a minimal set also avoids a real trap.
`nvidia-utils` and `pipewire-jack` are reachable only through *virtual*
dependencies — `opengl-driver` and `jack` — which `mesa` and `jack2` also
provide. Trimming them as "redundant" could leave a rebuild with mesa and no
nvidia driver. Being explicit removes the guesswork.

Packages installed purely as dependencies are still omitted; they return on
their own.

`setup.sh` pins every package to the **2026/08/22** Arch Archive snapshot —
the date of the last full upgrade, not the date the script was written.

---

## Base and boot

| Package | Reason |
|---|---|
| `base`, `base-devel` | Minimal Arch set, plus the build tools `makepkg` needs for AUR packages |
| `sudo` | `setup.sh` and daily admin |
| `grub`, `efibootmgr` | Bootloader, and the EFI boot entries `grub-install` writes |
| `os-prober` | Finds the Windows install. The `reboot-windows` alias reboots into the `osprober-efi-40C7-5064` entry |
| `intel-ucode` | CPU microcode, loaded by the `microcode` mkinitcpio hook |

## Kernels and firmware

| Package | Reason |
|---|---|
| `linux` | Daily driver |
| `linux-lts` | Fallback when a mainline bump breaks nvidia or the NIC |
| `linux-headers`, `linux-lts-headers` | DKMS builds `atlantic` against **both** kernels |
| `linux-firmware`, `linux-firmware-nvidia` | Device firmware; the nvidia set is split out upstream and `nvidia-open` needs it |
| `sof-firmware` | Onboard audio DSP |

## Graphics

An Intel iGPU and an nvidia dGPU, so both stacks are present.

| Package | Reason |
|---|---|
| `nvidia-open`, `nvidia-utils` | The dGPU, and the EGL/Vulkan/VA-API libraries Hyprland renders through |
| `intel-media-driver`, `vulkan-intel` | VA-API decode and Vulkan on the iGPU |
| `mesa-utils` | Diagnosing which GPU a program landed on |

`setup.sh` writes `/etc/modprobe.d/nvidia.conf` with `nvidia-drm modeset=1`,
which Hyprland requires on nvidia. Since `mkinitcpio.conf` uses the `kms` hook,
the drop-in must be baked into the initramfs — hence the `mkinitcpio -P`.

## Desktop (Hyprland / Wayland)

| Package | Reason |
|---|---|
| `hyprland` | The compositor |
| `waybar` | Status bar, `exec-once`. Pulls in `playerctl`, which drives the media keys |
| `wofi` | Launcher, SUPER+TAB |
| `swaybg` | Wallpaper, `exec-once` |
| `kitty` | Terminal, SUPER+T |
| `thunar` | File manager, SUPER+E via `$fileManager` |
| `ttf-jetbrains-mono-nerd` | Named in `waybar/style.css`; kitty inherits it as default monospace |
| `wl-clipboard`, `xclip` | Clipboard for Wayland-native and XWayland programs respectively |
| `wayland-utils` | Checking which protocols the compositor exposes |

## Audio

| Package | Reason |
|---|---|
| `pipewire-pulse`, `pipewire-alsa`, `pipewire-jack` | The audio server, plus ALSA and JACK compatibility |
| `alsa-utils` | `alsamixer` when nothing comes out |

These pull in `wireplumber`, which provides `wpctl` — every volume binding in
`hyprland.conf` calls it.

## Peripherals

| Package | Reason |
|---|---|
| `bluez`, `bluez-utils` | `bluetooth.service` is enabled; `bluetoothctl` pairs from the terminal |
| `usbutils` | `lsusb` |
| `libwacom` | No tablet attached, but `hyprland` → `libinput` → `libwacom` brings it regardless |

## Networking

| Package | Reason |
|---|---|
| `atlantic-dkms` *(AUR)* | **This board's ethernet.** `enp3s0` binds to the `atlantic` driver. The first thing to reconsider on other hardware |
| `networkmanager` | Manages `enp3s0` and `wlan0` |
| `iwd` | Wifi backend. `wlan0` is down; ethernet is the live link |
| `openssh` | `sshd` for remote login, and git over SSH |
| `tailscale` | Mesh VPN; `tailscale0` is up |
| `bind` | `dig` and `nslookup`. The daemon is not enabled |
| `ethtool`, `wakeonlan` | Inspecting the Aquantia link, arming and sending Wake-on-LAN |
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

`setup.sh` also clones two zsh plugins at pinned commits: `zsh-autosuggestions`
and `fast-syntax-highlighting`.

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

`go` is absent from `packages.txt` — it arrives as a build dependency of `yay`.

### Outside pacman

Pinned in `setup.sh` because no repo package matches the wanted version, and
because nvim references several by absolute path.

| Tool | Version | Source | Used by |
|---|---|---|---|
| Claude Code | 2.1.250 | native installer | CLI; self-updates afterwards |
| `pyright` | 1.1.413 | npm | `lsp/python.lua` |
| `ruff` | 0.16.4 | `uv tool` | `lsp/ruff.lua` |
| `csharp-ls` | 0.18.0 | `dotnet tool` | `lsp/csharp.lua` |
| `codelldb` | 1.11.5 | vsix | `plugins/dap.lua:19` |
| `debugpy` | 1.8.21 | uv venv | `dap.lua:46`, kept out of project venvs |
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

---

## Loose ends

**The brightness keys are laptop-only, annotated in place.**
`XF86MonBrightness{Up,Down}` call `brightnessctl`, which drives a laptop panel
backlight. They are kept active with a remark above them: they work on the
laptop and do nothing here, where `DP-3`'s brightness lives in the monitor's
own OSD.

The rule: **`hyprland.conf` is shared with the laptop, so a one-machine
binding gets a remark, not a deletion.** `packages.txt` is not shared.

**`iwd` is kept though `wlan0` is down.** The Qualcomm WCN785x Wi-Fi 7 hardware
is real; ethernet is simply the live link. It is the fallback if the Aquantia
NIC ever fails.

**`xf86-video-intel` was removed** (2026-08-28) — an X.org DDX driver on a
Wayland-only desktop, with nothing depending on it.

**`libwacom` is listed but was never a choice.** No tablet is attached; it
arrives because Hyprland does all input through `libinput`, which requires it.
It is listed because it is explicitly installed, not because it is wanted.

**No credentials are captured.** `~/.ssh`, the tailscale auth key, and
`~/.claude/.credentials.json` are outside both repos. `setup.sh` clones the
dotfiles over HTTPS, needing no key, then switches `origin` to SSH for pushing.
