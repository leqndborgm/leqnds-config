{ pkgs, inputs, config, ... }:
let
  c = config.lib.stylix.colors;

  colorsFile = pkgs.writeText "colors.css" ''
    @define-color base00 #${c.base00};
    @define-color base01 #${c.base01};
    @define-color base02 #${c.base02};
    @define-color base03 #${c.base03};
    @define-color base04 #${c.base04};
    @define-color base05 #${c.base05};
    @define-color base06 #${c.base06};
    @define-color base07 #${c.base07};
    @define-color base08 #${c.base08};
    @define-color base09 #${c.base09};
    @define-color base0A #${c.base0A};
    @define-color base0B #${c.base0B};
    @define-color base0C #${c.base0C};
    @define-color base0D #${c.base0D};
    @define-color base0E #${c.base0E};
    @define-color base0F #${c.base0F};
  '';

  # Merge static config files with generated colors
  configDir = pkgs.runCommand "ags-config" { } ''
    mkdir -p $out
    cp -r ${./config}/. $out/
    chmod -R +w $out
    # Prepend generated colors to style.css so no @import needed
    cat ${colorsFile} $out/style.css > $out/style-merged.css
    mv $out/style-merged.css $out/style.css
  '';
in
{
  home.packages = [
    inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.agsFull
    pkgs.libqalculate # `qalc` — backend for the launcher's calculator mode (= prefix)
  ];

  home.file.".config/ags".source = configDir;

  # The AGS Network widget replaces nm-applet. networkmanagerapplet ships an XDG
  # autostart entry that hyprland's xdg-desktop-autostart.target keeps relaunching,
  # so removing it from exec-once isn't enough — override the entry as Hidden.
  # (nm-connection-editor from the same package stays available for advanced settings.)
  xdg.configFile."autostart/nm-applet.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  systemd.user.services.ags = {
    Unit = {
      Description = "AGS Desktop Shell";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.agsFull}/bin/ags run ${configDir}/app.ts";
      Restart = "on-failure";
      RestartSec = "3s";
      Environment = [
        "WAYLAND_DISPLAY=wayland-1"
        "XDG_RUNTIME_DIR=/run/user/%U"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
