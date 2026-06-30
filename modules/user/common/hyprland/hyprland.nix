{
  host,
  config,
  pkgs,
  ...
}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    keyboardLayout
    stylixImage
    ;
in {
  home.packages = with pkgs; [
    awww
    grim
    slurp
    wl-clipboard
    swappy
    jq
    ydotool
    hyprpolkitagent
    hyprland-qtutils # needed for banners and ANR messages
    hyprsunset # blue-light filter daemon, toggled via toggle-bluelight
  ];

  home.file."Pictures/Screenshots/.keep".text = "";
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww wallpaper daemon";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  systemd.user.services.set-wallpaper = {
    Unit = {
      Description = "Set stylix wallpaper via swww";
      After = ["swww-daemon.service"];
      Requires = ["swww-daemon.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = toString (pkgs.writeShellScript "set-wallpaper" ''
        sleep 2
        ${pkgs.awww}/bin/awww img ${stylixImage}
      '');
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
  # Blue-light filter daemon. Starts in identity mode (filter off); the
  # toggle-bluelight script flips it on/off via `hyprctl hyprsunset …`.
  systemd.user.services.hyprsunset = {
    Unit = {
      Description = "hyprsunset blue-light filter daemon";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset --identity";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Place Files Inside Home Directory
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../../../wallpapers;
      recursive = true;
    };
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    configType = "hyprlang";
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
    xwayland = {
      enable = true;
    };
    settings = {
      "$modifier" = "SUPER";
      exec-once = [
        "wl-paste --type text --watch cliphist store # Stores only text data"
        "wl-paste --type image --watch cliphist store # Stores only image data"
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
        "pypr &"
      ];

      input = {
        kb_layout = "${keyboardLayout}";
        kb_options = [
          "grp:alt_caps_toggle"
          "caps:super"
        ];
        numlock_by_default = true;
        repeat_delay = 300;
        follow_mouse = 1;
        float_switch_override_focus = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          scroll_factor = 0.8;
        };
      };

      general = {
        layout = "dwindle";
        gaps_in = 6;
        gaps_out = 8;
        border_size = 2;
        resize_on_border = true;
        "col.active_border" = "rgb(${config.lib.stylix.colors.base08}) rgb(${config.lib.stylix.colors.base0C}) 45deg";
        "col.inactive_border" = "rgb(${config.lib.stylix.colors.base01})";
      };

      misc = {
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = false;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        vrr = 0; #Variable Refresh Rate  Might need to set to 0 for NVIDIA/AQ_DRM_DEVICES
        # Screen flashing to black momentarily or going black when app is fullscreen
        # Try setting vrr to 0
      };

      dwindle = {
        preserve_split = true;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          ignore_opacity = false;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2; # change to 1 if want to disable
        enable_hyprcursor = false;
        warp_on_change_workspace = 2;
        no_warps = true;
      };

      master = {
        new_status = "master";
        new_on_top = 1;
        mfact = 0.5;
      };

      # Frosted-glass blur for the AGS notification surfaces. The gtk-layer-shell
      # namespaces are set explicitly on the Astal windows (namespace=…). Without
      # blur the translucent panels render as a flat dark slab over the wallpaper.
      # NOTE: Hyprland 0.55 changed the INI layerrule syntax — effects are now
      # `field = value` pairs and the matcher is `match:namespace = <regex>`.
      # Booleans use `= on`; valued effects like ignore_alpha take a bare value.
      layerrule = [
        "blur = on, match:namespace = notification-center"
        "ignore_alpha 0.15, match:namespace = notification-center"
        "blur = on, match:namespace = notif-popups"
        "ignore_alpha 0.15, match:namespace = notif-popups"
        "blur = on, match:namespace = launcher"
        "ignore_alpha 0.15, match:namespace = launcher"
      ];

      env = [
        "NIXOS_OZONE_WL, 1"
        "NIXPKGS_ALLOW_UNFREE, 1"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "GDK_BACKEND, wayland, x11"
        "CLUTTER_BACKEND, wayland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
        "SDL_VIDEODRIVER, x11"
        "MOZ_ENABLE_WAYLAND, 1"
        # First entry is the primary (card1 = Intel iGPU, drives eDP-1); the
        # NVIDIA dGPU (card2) must be listed too or Hyprland never enumerates
        # HDMI-A-3, since the external port is wired to the dGPU.
        # card0 = EFI simple-framebuffer, NOT a real GPU — do not use it.
        # NOTE: do NOT use /dev/dri/by-path/* here — AQ_DRM_DEVICES separates
        # entries with ':', and the by-path names contain ':' themselves
        # (pci-0000:00:02.0), so Aquamarine splits them into garbage, finds no
        # GPU, and aborts. Use the plain card nodes.
        "AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
        "EDITOR,nvim"
      ];
    };

    extraConfig = "
      monitor=,preferred,auto,auto
      ${extraMonitorSettings}
      source = ~/.config/hypr/monitors.conf
    ";
  };
}
