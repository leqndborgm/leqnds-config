{host, ...}: let
  inherit (import ../../../hosts/${host}/variables.nix) waybarChoice;
in {
  imports = [
    ../common/bash.nix
    ../common/bashrc-personal.nix
    ../common/btop.nix
    ../common/fastfetch
    ../common/gh.nix
    ../common/ghostty.nix
    ../common/git.nix
    ../common/htop.nix
    ../common/hyprland
    ../common/kitty.nix
    ../common/nixvim.nix
    ../common/rofi
    ../common/qt.nix
    ../common/scripts
    ../common/starship.nix
    ../common/stylix.nix
    ../common/stylix-home.nix
    ../common/swappy.nix
    ../common/swaync.nix
    ../common/virtmanager.nix
    waybarChoice
    ../common/wezterm.nix
    ../common/wlogout
    ../common/xdg.nix
    ../common/yazi
    ../common/zoxide.nix
    ../common/zsh
    ./binds.nix
    ./ssh.nix
  ];
}
