{pkgs, ...}: {
  stylix = {
    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
    targets.kitty.variant256Colors = true;
  };
}
