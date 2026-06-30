{pkgs}:
pkgs.writeShellScriptBin "wp-rotation" ''
  #!/usr/bin/env bash

  WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
  INTERVAL=300  # Alle 5 Minuten

  # Kill existing wp-rotation processes (except this one)
  for pid in $(pidof -o %PPID -x wp-rotation); do
    kill $pid
  done

  if ! pgrep -x "awww-daemon" > /dev/null; then
    ${pkgs.awww}/bin/awww-daemon &
    sleep 1
  fi

  while true; do
    FILE=$(find -L "$WALLPAPER_DIR" -type f -iname '*.jpg' | shuf -n 1)

    if [ -n "$FILE" ]; then
      echo "✅ Wechsle Wallpaper: $FILE"
      ${pkgs.awww}/bin/awww img "$FILE" --transition-type random --transition-duration 2
    else
      echo "⚠️  Keine JPG-Dateien gefunden in $WALLPAPER_DIR (inkl. Symlinks)"
    fi

    sleep "$INTERVAL"
  done
''
