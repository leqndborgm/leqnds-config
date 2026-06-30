{pkgs}:
pkgs.writeShellScriptBin "toggle-bluelight" ''
  #!/usr/bin/env bash

  # Warm colour temperature for the blue-light filter (Kelvin).
  TEMP=3500
  # Track state via a marker file so the toggle is robust regardless of
  # the hyprsunset IPC state.
  STATE="''${XDG_RUNTIME_DIR:-/tmp}/bluelight.state"

  hyprctl=${pkgs.hyprland}/bin/hyprctl
  notify=${pkgs.libnotify}/bin/notify-send

  if [ -f "$STATE" ]; then
    "$hyprctl" hyprsunset identity
    rm -f "$STATE"
    "$notify" -a "Blaulichtfilter" "Blaulichtfilter aus" \
      "Farbtemperatur zurueckgesetzt" -i weather-clear
  else
    "$hyprctl" hyprsunset temperature "$TEMP"
    touch "$STATE"
    "$notify" -a "Blaulichtfilter" "Blaulichtfilter an" \
      "Farbtemperatur ''${TEMP}K" -i weather-clear-night
  fi
''
