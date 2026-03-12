{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
    configPackages = [pkgs.hyprland];
  };
  services = {
    flatpak.enable = true; # Enable Flatpak
  };
  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "5s";
    };
    path = [pkgs.flatpak];
    script = ''
      for i in {1..5}; do
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && exit 0
        echo "Flatpak repo addition failed, retrying in 5 seconds... ($i/5)"
        sleep 5
      done
      exit 1
    '';
  };
}
