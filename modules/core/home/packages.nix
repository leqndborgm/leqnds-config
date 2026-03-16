{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    blender # Animation software
    ytmdl # Tool For Downloading Audio From YouTube
    vesktop # Better Discord
  ];
}
