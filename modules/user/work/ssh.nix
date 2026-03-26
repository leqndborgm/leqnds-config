{lib, ...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = lib.mkForce false;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519_github";
      };
      "gitlab" = {
        hostname = "gitlab.quasiris.de";
        port = 2222;
        user = "mbr";
        identityFile = "~/.ssh/id_ed25519";
      };
      "*.quasiris.de" = {
        user = "mbr";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
