{host, ...}: let
  inherit (import ../../hosts/${host}/variables.nix) waybarChoice;
in {
  imports = [
    ../amfora.nix
    ../bash.nix
    ../bashrc-personal.nix
    ../btop.nix
    ../cava.nix
    ../emoji.nix
    ../fastfetch
    ../gh.nix
    ../ghostty.nix
    ../git.nix
    ../htop.nix
    ../hyprland
    ../kitty.nix
    ../nvf.nix
    ../rofi
    ../qt.nix
    ../scripts
    ../starship.nix
    ../stylix.nix
    ../stylix-home.nix
    ../swappy.nix
    ../swaync.nix
    ../virtmanager.nix
    waybarChoice
    ../wezterm.nix
    ../wlogout
    ../xdg.nix
    ../yazi
    ../zoxide.nix
    ../zsh
  ];
}
