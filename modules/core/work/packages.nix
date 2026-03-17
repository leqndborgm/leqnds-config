{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (teams-for-linux.override {electron_39 = electron_39-bin;}) # Microsoft Teams
    electron_40-bin # Cross platform desktop shell
    xdg-utils # Needed for opening links and better integration
    thunderbird-latest-unwrapped # Thunderbird Email client
    cursor-cli # Cursor CLI
    python313Packages.mcp # MCP Python SDK
    slack # Slack Client
    zoom-us # Video Conferene Tool
  ];
}
