{
  pkgs,
  host,
  ...
}: let
  inherit (import ../../../hosts/${host}/variables.nix) stylixImage;
in {
  # Styling Options
  stylix = {
    enable = true;
    targets.plymouth.enable = true;
    targets.kmscon.enable = false;
    image = stylixImage;
    polarity = "dark";
    opacity.terminal = 0.6;

    base16Scheme = {
      base00 = "0a0a10";
      base01 = "151521";
      base02 = "222233";
      base03 = "7eb8c8"; # comments — teal, readable on transparency
      base04 = "5aa0af"; # darker cyan
      base05 = "c8c8e0"; # light desaturated grey
      base06 = "8f6acb"; # muted purple
      base07 = "d0d0f0";
      base08 = "d36fa3"; # darker pink
      base09 = "c08050"; # muted orange
      base0A = "c7c96d"; # muted yellow-green
      base0B = "64af6a"; # dark green
      base0C = "5faebc"; # grey-blue
      base0D = "505caa"; # dark violet-blue
      base0E = "8f6acb"; # muted purple
      base0F = "b04c4c"; # dark red
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 18;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.fira-code;
        name = "Fira Code Nerd Font";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sizes = {
        applications = 13;
        terminal = 15;
        desktop = 12;
        popups = 13;
      };
    };
  };
}
