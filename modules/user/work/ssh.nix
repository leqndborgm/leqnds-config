{lib, ...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = lib.mkForce false;
    # Host-specific internal entries live in an untracked ~/.ssh/config.local
    # (kept out of this public repo). Create it manually on the machine.
    includes = ["config.local"];
    settings = {
      "github.com" = {
        HostName = "github.com";
        IdentityFile = "~/.ssh/id_ed25519_github";
      };
      "git.ai.fh-erfurt.de" = {
        HostName = "git.ai.fh-erfurt.de";
        IdentityFile = "~/.ssh/gitlab_fh";
      };
    };
  };
}
