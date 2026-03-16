{host, ...}: let
  inherit (import ../../../hosts/${host}/variables.nix) gitUsername gitEmail;
in {
  programs.git = {
    enable = true;
    settings.user.name = "${gitUsername}";
    settings.user.email = "${gitEmail}";
  };
}
