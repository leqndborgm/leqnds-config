{...}: {
  imports = [
    ../common.nix
    ../common/steam.nix
    ./user.nix
    ./packages.nix
  ];
}
