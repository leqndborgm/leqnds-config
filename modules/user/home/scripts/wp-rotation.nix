{pkgs}:
pkgs.writeShellScriptBin "wp-rotation" ''
  #!/usr/bin/env bash

  WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
  INTERVAL=300  # Alle 5 Minuten

  if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
  fi

  while true; do
    FILE=$(find -L "$WALLPAPER_DIR" -type f -iname '*.jpg' | shuf -n 1)

    if [ -n "$FILE" ]; then
      echo "✅ Wechsle Wallpaper: $FILE"
      swww img "$FILE" --transition-type any --transition-duration 2
    else
      echo "⚠️  Keine JPG-Dateien gefunden in $WALLPAPER_DIR (inkl. Symlinks)"
    fi

    sleep "$INTERVAL"
  done
''
