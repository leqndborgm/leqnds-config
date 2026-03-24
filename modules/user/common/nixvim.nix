{
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
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
      hlsearch = true;       # Enable search highlighting
      incsearch = true;      # Incremental search
      termguicolors = true;  # Enable 24-bit RGB color
      scrolloff = 8;         # Keep 8 lines above/below cursor
      signcolumn = "yes";    # Always show sign column
      updatetime = 50;       # Faster completion
      cursorline = true;     # Highlight the current line
    };

    # UI & Aesthetics
    plugins.web-devicons.enable = true;

    plugins.lualine = {
      enable = true;
      settings.options.theme = "auto"; # Matches your system theme
    };

    plugins.bufferline = {
      enable = true;
      settings.options.offsets = [
        {
          filetype = "neo-tree";
          text = "File Explorer";
          highlight = "Directory";
          text_align = "left";
        }
      ];
    };

    plugins.noice = {
      enable = true;
      settings = {
        messages.enabled = true;
        notify.enabled = true;
        lsp.progress.enabled = true;
        popupmenu.enabled = true;
      };
    };

    plugins.notify = {
      enable = true;
      settings.background_colour = "#000000";
    };

    plugins.alpha = {
      enable = true;
      theme = "dashboard";
    };

    # Syntax & Code Structure
    plugins.treesitter = {
      enable = true;
      settings.indent.enable = true;
      settings.highlight.enable = true;
    };

    plugins.indent-blankline = {
      enable = true;
      settings.scope.enabled = true;
    };

    # Git Integration
    plugins.gitsigns = {
      enable = true;
      settings.current_line_blame = true; # Shows who wrote the line
    };

    # File Explorer
    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        window.width = 30;
      };
    };

    # Fuzzy Finder
    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>pf" = "find_files";
        "<leader>ps" = "live_grep";
        "<leader>pb" = "buffers";
        "<leader>ph" = "help_tags";
      };
    };

    # LSP and Completion
    plugins.lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        clangd.enable = true;
        pyright.enable = true;
        jdtls.enable = true;
        ts_ls.enable = true;
        html.enable = true;
        phpactor.enable = true;
        marksman.enable = true;
      };
      keymaps.lspBuf = {
        K = "hover";
        gD = "references";
        gd = "definition";
        gi = "implementation";
        gt = "type_definition";
        "<leader>ca" = "code_action";
        "<leader>rn" = "rename";
      };
    };

    plugins.cmp = {
      enable = true;
      settings = {
        autoEnableSources = true;
        sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
          {name = "luasnip";}
        ];
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-e>" = "cmp.mapping.close()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
      };
    };

    plugins.luasnip.enable = true;

    # Utility Plugins (QOL)
    plugins.comment.enable = true; # "gcc" to comment line, "gc" in visual mode
    plugins.nvim-autopairs.enable = true;
    plugins.surround.enable = true;
    plugins.which-key.enable = true;

    # Highlight Overrides (for readability)
    highlight = {
      Comment = {
        fg = "#94e2d5"; # Bright teal for readable comments
        italic = true;
      };
    };

    # Keymaps
    globals.mapleader = " ";

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle File Explorer";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Move to left split";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Move to bottom split";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Move to top split";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Move to right split";
      }
    ];
  };
}
