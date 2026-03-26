{lib, ...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = lib.mkForce false;
  };
}
