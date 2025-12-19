{pkgs, ...}:
pkgs.writeShellScriptBin "wallsetter" ''

  TIMEOUT=720

  for pid in $(pidof -o %PPID -x wallsetter); do
  	kill $pid
  done

  if ! [ -d ~/Pictures/Wallpapers ]; then notify-send -t 5000 "~/Pictures/Wallpapers does not exist" && exit 1; fi
  if [ $(find -L ~/Pictures/Wallpapers -type f | wc -l) -lt 2 ]; then	notify-send -t 9000 "The wallpaper folder is expected to have more than 1 image. Exiting Wallsetter." && exit 1; fi

  # Start swww if it's not running
  if ! ${pkgs.swww}/bin/swww query &>/dev/null; then
      ${pkgs.swww}/bin/swww init &
      sleep 2
  fi

  while true; do
    WALLPAPER=$(find -L ~/Pictures/Wallpapers -type f | shuf -n 1)

    while [ "$WALLPAPER" == "$PREVIOUS" ]; do
      WALLPAPER=$(find -L ~/Pictures/Wallpapers -type f | shuf -n 1)
    done

  	PREVIOUS=$WALLPAPER

  	${pkgs.swww}/bin/swww img "$WALLPAPER" --transition-type random --transition-step 15 --transition-fps 75
  	sleep $TIMEOUT
  done
''
