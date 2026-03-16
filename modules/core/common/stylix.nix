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
    image = stylixImage;
    polarity = "dark";
    opacity.terminal = 0.6;

    base16Scheme = {
      base00 = "0a0a10";
      base01 = "151521";
      base02 = "222233";
      base03 = "33334d";
      base04 = "5aa0af"; # dunkleres Cyan
      base05 = "c8c8e0"; # helles, entsättigtes Grau
      base06 = "8f6acb"; # gedeckteres Lila
      base07 = "d0d0f0";
      base08 = "d36fa3"; # dunkleres Pink
      base09 = "c08050"; # gedecktes Orange
      base0A = "c7c96d"; # gedecktes Gelbgrün
      base0B = "64af6a"; # dunkles Grün
      base0C = "5faebc"; # graublau
      base0D = "505caa"; # dunkles Violettblau
      base0E = "8f6acb"; # gedeckteres Lila
      base0F = "b04c4c"; # dunkles Rot
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
