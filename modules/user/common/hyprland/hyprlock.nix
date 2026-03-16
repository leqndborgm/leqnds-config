{
  config,
  pkgs,
  ...
}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 10;
        hide_cursor = true;
      };

      background = [
        {
          path = "${config.home.homeDirectory}/leqnds-config/modules/user/common/hyprland/lockscreen/lockscreen.jpg";
          blur_passes = 1;
          blur_size = 2;
        }
      ];

      image = [
        {
          path = "${config.home.homeDirectory}/.config/face.jpg";
          size = 160;
          border_size = 4;
          border_color = "rgba(110, 80, 180, 0.6)";
          rounding = -1;
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 60";
          position = "0, -75";
          dots_center = true;
          fade_on_empty = false;
          placeholder_text = "Enter your passcode...";
          font_color = "rgba(220, 220, 255, 0.85)";
          inner_color = "rgba(130, 100, 200, 0.25)";
          outer_color = "rgba(25, 25, 25, 0.8)";
          outline_thickness = 5;
          rounding = 10;
          shadow_passes = 2;
          fail_color = "rgba(117, 18, 28, 0.6)";
          fail_text = "Wrong passcode...";
        }
      ];

      label = [
        {
          text = "<< $USER >>";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 16;
          color = "rgba(200, 200, 255, 0.8)";
          position = "0, -15";
          halign = "center";
          valign = "center";
        }

        {
          text = "$TIME";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 20;
          color = "rgba(220, 220, 255, 0.9)";
          position = "0, -15";
          halign = "center";
          valign = "top";
        }

        {
          text = "$LAYOUT";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 20;
          color = "rgba(220, 220, 225, 0.9)";
          position = "0, 0";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
