{host, ...}: let
  inherit (import ../../../../hosts/${host}/variables.nix) animChoice;
in {
  imports = [
    animChoice
    ./binds.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./pyprland.nix
    ./windowrules.nix
  ];
}
