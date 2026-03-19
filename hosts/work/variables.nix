{
  # Git Configuration
  gitUsername = "Martin Bothe";
  gitEmail = "martin.bothe@quasiris.de";

  # Hyprland Settings
  extraMonitorSettings = "monitor=HDMI-A-1,preferred,auto,1";

  # Program Options
  browser = "brave";
  terminal = "kitty";
  keyboardLayout = "de";
  consoleKeyMap = "de";

  # For Nvidia Prime support
  intelID = "PCI:0:2:0";
  nvidiaID = "PCI:1:0:0";

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = true;

  # Set Stylix Image
  stylixImage = ../../wallpapers/holdingHands.jpg;

  # Set Waybar
  waybarChoice = ../../modules/user/common/waybar/waybar-alt.nix;

  # Set Animation style
  animChoice = ../../modules/user/common/hyprland/animations-dynamic.nix;

  # Enable Thunar GUI File Manager
  thunarEnable = false;
}
