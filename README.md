<h1 align="center">leqnds-config</h1>

<p align="center">My NixOS flake — Hyprland, a hand-built AGS shell, and everything themed by Stylix.</p>

<p align="center">
  <img src="https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white" alt="NixOS">
  <img src="https://img.shields.io/badge/WM-Hyprland-00AABB?logo=hyprland&logoColor=white" alt="Hyprland">
  <img src="https://img.shields.io/badge/Shell-AGS%20(GTK4)-1f6feb" alt="AGS">
  <img src="https://img.shields.io/badge/Theme-Stylix-845EC2" alt="Stylix">
  <img src="https://img.shields.io/badge/License-MIT-3fb950" alt="MIT">
</p>

---

### ✨ Highlights

- 🪟 **Custom AGS shell** — bar, launcher, notifications, calendar, power menu, OSD. No waybar, no swaync.
- 🎨 **Themed once, everywhere** — one Stylix base16 scheme drives terminals, GTK, Neovim, lockscreen *and* the bar.
- 🧠 **AI in Neovim** — local Ollama (Avante) + Claude Code, ghost-text completion.
- 💻 **Many machines, one flake** — see below.

### 💻 Machines

| build with `.#` | where | notes |
|---|---|---|
| `amd` | home | AMD desktop |
| `intel` | home | Intel box |
| `nvidia-laptop` | home | NVIDIA laptop |
| `work` | work | ThinkPad · Intel + NVIDIA prime · Ollama |

```bash
sudo nixos-rebuild switch --flake .#work
```

### 🚀 Make it yours

```bash
git clone https://github.com/leqndborgm/leqnds-config ~/leqnds-config
cd ~/leqnds-config
```

1. Drop your hardware scan into `hosts/<host>/hardware.nix`
2. Tweak `hosts/<host>/variables.nix` (git user, monitors, GPU IDs, wallpaper…)
3. `sudo nixos-rebuild switch --flake .#<host>`

> Flakes need to be enabled. `flake.lock` is intentionally untracked (regenerated per machine).

### 🗂️ Layout

```
flake.nix    # inputs + machine list
hosts/       # per-machine knobs + hardware
profiles/    # drivers + host → buildable system
modules/
  core/  → common · home · work   # system side
  user/  → common · home · work   # home-manager side
```

> A machine sees `common` **plus** its own `home`/`work` set — work-only bits must live in `common/` or `work/`.

### 🙏 Credits

Built on [**ZaneyOS**](https://gitlab.com/Zaney/zaneyos) by Tyler Kelley — MIT, see [LICENSE](LICENSE).
