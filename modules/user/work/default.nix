{...}: {
  systemd.user.sessionVariables = {
    AQ_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card2";
  };

  imports = [
    ../common/ags
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
    ../common/virtmanager.nix
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
