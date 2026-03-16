{
  pkgs,
  username,
  ...
}: {
  home.packages = [
    (import ./emopicker9000.nix {inherit pkgs;})
    (import ./squirtle.nix {inherit pkgs;})
    (import ./wallsetter.nix {
      inherit pkgs;
      inherit username;
    })
    (import ./wp-rotation.nix {inherit pkgs;})
  ];
}
