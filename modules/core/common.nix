{inputs, ...}: {
  imports = [
    ./common/boot.nix
    ./common/flatpak.nix
    ./common/fonts.nix
    ./common/hardware.nix
    ./common/network.nix
    ./common/nfs.nix
    ./common/nh.nix
    ./common/packages.nix
    ./common/printing.nix
    ./common/security.nix
    ./common/services.nix
    ./common/starfish.nix
    ./common/stylix.nix
    ./common/syncthing.nix
    ./common/system.nix
    ./common/thunar.nix
    ./common/tuigreet.nix
    ./common/virtualisation.nix
    ./common/xserver.nix
    inputs.stylix.nixosModules.stylix
  ];
}
