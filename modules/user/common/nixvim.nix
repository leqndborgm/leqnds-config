{
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    luaLoader.enable = true;

    # Basic Options
    opts = {
      number = true;         # Show line numbers
      relativenumber = false; # Disable relative line numbers
      shiftwidth = 2;        # Tab width
      tabstop = 2;           # Tab width
      softtabstop = 2;       # Tab width
      expandtab = true;      # Use spaces instead of tabs
      smartindent = true;    # Auto indenting
      wrap = false;          # Disable line wrapping
      swapfile = false;      # Disable swap files
      backup = false;        # Disable backup files
      undofile = true;       # Enable persistent undo
      hlsearch = false;      # Clear search highlighting
      incsearch = true;      # Incremental search
      termguicolors = true;  # Enable 24-bit RGB color
      scrolloff = 8;         # Keep 8 lines above/below cursor
      signcolumn = "yes";    # Always show sign column
      updatetime = 50;       # Faster completion
    };

    # Syntax Highlighting
    plugins.treesitter = {
      enable = true;
      settings.indent.enable = true;
    };

    plugins.web-devicons.enable = true;

    # File Explorer
    plugins.neo-tree = {
      enable = true;
      closeIfLastWindow = true;
      window.width = 30;
    };

    # Fuzzy Finder
    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>pf" = "find_files";
        "<leader>ps" = "live_grep";
      };
    };

    # Highlight Overrides (for readability)
    highlight = {
      Comment = {
        fg = "#94e2d5"; # Teal/Light Cyan (Catppuccin-like) for bright, readable comments
        italic = true;
      };
    };

    # Keymaps
    globals.mapleader = " "; # Space as leader key

    keymaps = [
      {
        mode = "n";
        key = "<leader>pv";
        action = "<cmd>Ex<CR>";
        options.desc = "Back to Netrw";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle File Explorer";
      }
    ];
  };
}
