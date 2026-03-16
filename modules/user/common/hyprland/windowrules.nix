{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        "tag +file-manager, match:class ^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
        "tag +terminal, match:class ^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$"
        "tag +browser, match:class ^(Brave-browser(-beta|-dev|-unstable)?)$"
        "tag +browser, match:class ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
        "tag +browser, match:class ^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
        "tag +browser, match:class ^([Tt]horium-browser|[Cc]achy-browser)$"
        "tag +projects, match:class ^(codium|codium-url-handler|VSCodium)$"
        "tag +projects, match:class ^(VSCode|code-url-handler)$"

        "tag +im, match:class ^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
        "tag +im, match:class ^([Ff]erdium)$"
        "tag +im, match:class ^([Ww]hatsapp-for-linux)$"
        "tag +im, match:class ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
        "tag +im, match:class ^(teams-for-linux)$"
        "tag +games, match:class ^(gamescope)$"
        "tag +games, match:class ^(steam_app_\\d+)$"
        "tag +gamestore, match:class ^([Ss]team)$"
        "tag +gamestore, match:title ^([Ll]utris)$"
        "tag +gamestore, match:class ^(com.heroicgameslauncher.hgl)$"

        "tag +settings, match:class ^(gnome-disks|wihotspot(-gui)?)$"
        "tag +settings, match:class ^([Rr]ofi)$"
        "tag +settings, match:class ^(file-roller|org.gnome.FileRoller)$"
        "tag +settings, match:class ^(nm-applet|nm-connection-editor|blueman-manager)$"
        "tag +settings, match:class ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
        "tag +settings, match:class ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
        "tag +settings, match:class (xdg-desktop-portal-gtk)"
        "tag +settings, match:class (.blueman-manager-wrapped)"
        "tag +settings, match:class (nwg-displays)"
        "move 72% 7%, match:title ^(Picture-in-Picture)$"

        "center 1, match:class ^([Ff]erdium)$"
        "float 1, match:class ^([Ww]aypaper)$"
        "center 1, match:class ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
        "center 1, match:class ([Tt]hunar), match:title negative:(.*[Tt]hunar.*)"
        "center 1, match:title ^(Authentication Required)$"
        "float 1, match:class ^([Ff]erdium)$"
        "float 1, match:title ^(Picture-in-Picture)$"
        "float 1, match:class ^(mpv|com.github.rafostar.Clapper)$"
        "float 1, match:title ^(Authentication Required)$"
        "float 1, match:class (codium|codium-url-handler|VSCodium), match:title negative:(.*codium.*|.*VSCodium.*)"

        "float 1, match:class ^(com.heroicgameslauncher.hgl)$, match:title negative:(Heroic Games Launcher)"
        "float 1, match:class ^([Ss]team)$, match:title negative:^([Ss]team)$"
        "float 1, match:class ([Tt]hunar), match:title negative:(.*[Tt]hunar.*)"
        "float 1, match:initial_title (Add Folder to Workspace)"
        "float 1, match:initial_title (Open Files)"
        "float 1, match:initial_title (wants to save)"
        "size 70% 60%, match:initial_title (Open Files)"
        "size 70% 60%, match:initial_title (Add Folder to Workspace)"
        "size 70% 70%, match:tag settings*"

        "size 60% 70%, match:class ^([Ff]erdium)$"
        "opacity 1.0 1.0, match:tag browser*"
        "opacity 0.9 0.8, match:tag projects*"
        "opacity 0.94 0.86, match:tag im*"
        "opacity 0.9 0.8, match:tag file-manager*"
        "opacity 0.8 0.7, match:tag terminal*"
        "opacity 0.8 0.7, match:tag settings*"
        "opacity 0.8 0.7, match:class ^(gedit|org.gnome.TextEditor|mousepad)$"
        "opacity 0.9 0.8, match:class ^(seahorse)$"

        "opacity 0.95 0.75, match:title ^(Picture-in-Picture)$"
        "pin 1, match:title ^(Picture-in-Picture)$"
        "keep_aspect_ratio 1, match:title ^(Picture-in-Picture)$"
        "no_blur 1, match:tag games*"
        "fullscreen 1, match:tag games*"
        "float 1, match:class ^(kitty-dropterm)$"
        "center 1, match:class ^(kitty-dropterm)$"
        "opacity 0.9 0.9, match:class ^(kitty-dropterm)$"
      ];
    };
  };
}
