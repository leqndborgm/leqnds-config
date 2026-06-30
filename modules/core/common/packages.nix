{
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    firefox.enable = false; # Firefox is not installed by default
    hyprland.enable = true; # someone forgot to set this so desktop file is created
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    amfora # Fancy Terminal Browser For Gemini Protocol
    antigravity # Google KI IDE
    appimage-run # Needed For AppImage Support
    brave # Brave Browser
    brightnessctl # For Screen Brightness Control
    cargo
    cliphist # Clipboard manager using rofi menu
    clamav # Antivirus
    clamtk # Antivirus Frontend
    cmatrix # Matrix Movie Effect In Terminal
    direnv # Direnv for presentation tool
    duf # Utility For Viewing Disk Usage In Terminal
    eza # Beautiful ls Replacement
    file-roller # Archive Manager
    firefox # Firefox
    mesa-demos # glxinfo (renamed) needed for inxi diag util
    gemini-cli # Googles AI assistant
    tuigreet # The Login Manager (Sometimes Referred To As Display Manager)
    htop # Simple Terminal Based System Monitor
    hyprpicker # Color Picker
    eog # For Image Viewing
    inxi # CLI System Information Tool
    killall # For Killing All Instances Of Programs
    libnotify # For Notifications
    lm_sensors # Used For Getting Hardware Temps
    lolcat # Add Colors To Your Terminal Command Output
    lshw # Detailed Hardware # CLI System Information Tool
    nodejs
    mpv # Incredible Video Player
    ncdu # Disk Usage Analyzer With Ncurses Interface
    nixfmt # Nix Formatter
    black # Python Formatter
    prettierd # Prettier Formatter Daemon
    nwg-displays # configure monitor configs via GUI
    nemo # File Manager
    onefetch # provides zsaneyos build info on current system
    obsidian # for better organising
    pavucontrol # For Editing Audio Levels & Devices
    pciutils # Collection Of Tools For Inspecting PCI Devices
    pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
    playerctl # Allows Changing Media Volume Through Scripts
    php # php language
    python3
    ripgrep # Improved Grep
    socat # Needed For Screenshots
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    usbutils # Good Tools For USB Devices
    wget # Tool For Fetching Files With Links
    yazi # TUI File Manager
    jetbrains-toolbox # For Jetbrains IDEs
    gcc
    cmake
    gdb
    clang
    wireshark # Powerfull network protocoll analyzer
    gns3-gui # Graphical Network Simulator 3 GUI
    gns3-server # Graphical Network Simulatur 3 Server
  ];
}
