{
  pkgs,
  username,
  ...
}: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = username;
        command = "${pkgs.tuigreet}/bin/tuigreet --time --greeting Willkommen! --cmd Hyprland --remember"; # start Hyprland with a TUI login manager
      };
    };
  };
}
