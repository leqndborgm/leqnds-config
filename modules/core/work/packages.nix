{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    (teams-for-linux.override { electron_41 = electron_41-bin; }) # Microsoft Teams
    electron_41-bin # Cross platform desktop shell
    xdg-utils # Needed for opening links and better integration
    thunderbird-latest-unwrapped # Thunderbird Email client
    cursor-cli # Cursor CLI
    python313Packages.mcp # MCP Python SDK
    jetbrains.jdk
    maven
    openvpn
    slack # Slack Client
    zoom-us # Video Conferene Tool
    # oterm # Ollama TUI
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs # Claude Desktop Flake
    claude-code # Claude Code Integration
  ];
}
