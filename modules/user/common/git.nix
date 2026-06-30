{host, lib, ...}: let
  inherit (import ../../../hosts/${host}/variables.nix) gitUsername gitEmail;
in {
  programs.git = {
    enable = true;
    settings = lib.recursiveUpdate {
      user.name = "${gitUsername}";
      user.email = "${gitEmail}";
    } (lib.optionalAttrs (host == "work") {
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.format = "ssh";
      commit.gpgsign = true;
    });
    # Default signing key is id_ed25519 (internal GitLab). GitHub only verifies
    # SSH signatures against keys registered there, so sign GitHub remotes with
    # the GitHub key.
    includes = lib.optionals (host == "work") [
      {
        condition = "hasconfig:remote.*.url:git@github.com:**";
        contents.user.signingkey = "~/.ssh/id_ed25519_github.pub";
      }
    ];
  };
}
