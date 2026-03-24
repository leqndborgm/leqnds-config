{host, lib, ...}: let
  inherit (import ../../../hosts/${host}/variables.nix) gitUsername gitEmail;
in {
  programs.git = {
    enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
    extraConfig = (lib.optionalAttrs (host == "work") {
      user.signingkey = "~/.ssh/id_ed25519_github.pub";
      gpg.format = "ssh";
      commit.gpgsign = true;
    });
  };
}
