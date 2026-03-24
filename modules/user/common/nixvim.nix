{
  inputs,
  config,
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
      number = true;
      relativenumber = false;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      hlsearch = true;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      cursorline = true;
    };

    # UI & Aesthetics (VS Code Style)
    plugins.web-devicons.enable = true;

    plugins.lualine = {
      enable = true;
      settings.options = {
        theme = "auto";
        section_separators = { left = ""; right = ""; }; # Flatter, modern look
        component_separators = { left = "|"; right = "|"; };
      };
    };

    plugins.bufferline = {
      enable = true;
      settings.options = {
        separator_style = "thin"; # Clean VS Code-like separators
        offsets = [
          {
            filetype = "neo-tree";
            text = "EXPLORER";
            highlight = "Directory";
            text_align = "left";
          }
        ];
      };
    };

    # Breadcrumbs (Top bar)
    plugins.barbecue.enable = true;

    # Smooth Scrolling
    plugins.neoscroll.enable = true;

    # Color Previews (Hex codes)
    plugins.nvim-colorizer.enable = true;

    # Floating Terminal (VS Code style)
    plugins.toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        open_mapping = "[[<C-t>]]"; # Ctrl + t to toggle terminal
      };
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
      settings = {
        indent.enable = true;
        highlight.enable = true;
      };
    };

    plugins.indent-blankline = {
      enable = true;
      settings.scope.enabled = true;
    };

    # Symbol Outline (Right side)
    plugins.aerial = {
      enable = true;
      settings = {
        on_attach = config.lib.nixvim.mkRaw ''
          function(bufnr)
            vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
            vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
          end
        '';
      };
    };

    # Git Integration
    plugins.gitsigns = {
      enable = true;
      settings.current_line_blame = true;
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

    # Utility Plugins
    plugins.comment.enable = true;
    plugins.nvim-autopairs.enable = true;
    plugins.vim-surround.enable = true;
    plugins.which-key.enable = true;

    # Highlight Overrides
    highlight = {
      Comment = {
        fg = "#94e2d5";
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
        key = "<leader>o";
        action = "<cmd>AerialToggle!<CR>";
        options.desc = "Toggle Outline";
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
