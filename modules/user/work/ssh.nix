{lib, ...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = lib.mkForce false;
    settings = {
      "github.com" = {
        HostName = "github.com";
        IdentityFile = "~/.ssh/id_ed25519_github";
      };
      "git.ai.fh-erfurt.de" = {
        HostName = "git.ai.fh-erfurt.de";
        IdentityFile = "~/.ssh/gitlab_fh";
      };
      "gitlab" = {
        HostName = "gitlab.quasiris.de";
        Port = 2222;
        User = "mbe";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "*.quasiris.de" = {
        User = "mbe";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
