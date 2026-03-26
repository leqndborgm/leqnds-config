{
  inputs,
  config,
  pkgs,
  host,
  lib,
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
      relativenumber = true; # Changed to true for easier jumping
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

    # UI & Aesthetics
    plugins.web-devicons.enable = true;

    plugins.lualine = {
      enable = true;
      settings.options = {
        theme = "auto";
        section_separators = { left = ""; right = ""; };
        component_separators = { left = ""; right = ""; };
      };
    };

    plugins.bufferline = {
      enable = true;
      settings.options = {
        separator_style = "thin";
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

    # Better UI for selects and inputs
    plugins.dressing.enable = true;

    # Floating Terminal
    plugins.toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        open_mapping = "[[<C-t>]]";
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

    # Navigation
    plugins.flash = {
      enable = true;
      settings.labels = "asdfghjklqwertyuiopzxcvbnm";
    };

    plugins.oil = {
      enable = true;
      settings = {
        default_file_explorer = true;
        delete_to_trash = true;
        skip_confirm_for_simple_edits = true;
        view_options.show_hidden = true;
      };
    };

    plugins.todo-comments.enable = true;

    # Symbol Outline
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

    plugins.diffview.enable = true;

    # Diagnostics
    plugins.trouble = {
      enable = true;
      settings.auto_close = true;
    };

    # Formatting
    plugins.conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_fallback = true;
          timeout_ms = 500;
        };
        formatters_by_ft = {
          nix = ["nixfmt"];
          python = ["black"];
          javascript = ["prettierd" "prettier"];
          typescript = ["prettierd" "prettier"];
          html = ["prettierd" "prettier"];
          css = ["prettierd" "prettier"];
        };
      };
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
      extensions.todo-comments.enable = true;
    };

    # LSP
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

    # Completion Engine (High Performance)
    plugins.blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "default";
        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "mono";
        };
        sources = {
          default = ["lsp" "path" "snippets" "buffer"] ++ lib.optionals (host == "work") ["minuet"];
          providers.minuet = {
            name = "minuet";
            module = "minuet.blink";
            score_offset = 100;
          };
        };
      };
    };

    # AI (Ollama - Work only)
    plugins.ollama = {
      enable = host == "work";
      settings = {
        model = "deepseek-r1:70b"; # Deep reasoning for architecture
        url = "http://127.0.0.1:11434";
        prompts = {
          Refactor = {
            prompt = "Refactor the following code for better readability and performance. Maintain the same functionality:\n\n```$FT\n$TEXT\n```";
            action = "replace";
          };
          Explain = {
            prompt = "Explain how this code works in detail:\n\n```$FT\n$TEXT\n```";
            action = "display";
          };
          UnitTests = {
            prompt = "Generate comprehensive unit tests for this code using the standard testing framework for $FT:\n\n```$FT\n$TEXT\n```";
            action = "display";
          };
          FixBugs = {
            prompt = "Identify and fix any potential bugs or edge cases in this code:\n\n```$FT\n$TEXT\n```";
            action = "replace";
          };
        };
      };
    };

    # Cursor-like Agent
    plugins.avante = {
      enable = host == "work";
      settings = {
        provider = "ollama";
        vendors.ollama = {
          __inherited_from = "openai";
          api_key_name = "";
          endpoint = "http://127.0.0.1:11434/v1";
          model = "qwen2.5-coder:32b";
          parse_curl_args = config.lib.nixvim.mkRaw ''
            function(opts, code_opts)
              return {
                url = opts.endpoint .. "/chat/completions",
                headers = {
                  ["Accept"] = "application/json",
                  ["Content-Type"] = "application/json",
                },
                body = {
                  model = opts.model,
                  messages = require("avante.providers").openai.parse_messages(code_opts),
                  max_tokens = 2048,
                  stream = true,
                },
              }
            end
          '';
          parse_response_data = config.lib.nixvim.mkRaw ''
            function(data_stream, event_state, opts)
              require("avante.providers").openai.parse_response(data_stream, event_state, opts)
            end
          '';
        };
      };
    };

    # Local Ghost-Text (Line Completion)
    plugins.minuet = {
      enable = host == "work";
      settings = {
        provider = "ollama";
        provider_options.ollama = {
          model = "deepseek-coder-v2:16b";
          endpoint = "http://127.0.0.1:11434/v1/completions";
        };
        virtualtext.auto_trigger_ft = ["*"];
      };
    };

    plugins.luasnip = {
      enable = true;
      fromVscode = [
        {
          lazyLoad = true;
          paths = "${pkgs.vimPlugins.friendly-snippets}";
        }
      ];
    };

    # Utility Plugins
    plugins.comment.enable = true;
    plugins.nvim-autopairs.enable = true;
    plugins.vim-surround.enable = true;
    plugins.which-key.enable = true;

    # Highlight Overrides (Super Readable Colors)
    highlight = {
      Comment = {
        fg = "#94e2d5";
        italic = true;
      };
      Function = {
        fg = "#89b4fa";
        bold = true;
      };
      Keyword = {
        fg = "#cba6f7";
        bold = true;
      };
      String = {
        fg = "#a6e3a1";
      };
      Identifier = {
        fg = "#f38ba8";
      };
      Type = {
        fg = "#f9e2af";
      };
      Constant = {
        fg = "#fab387";
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
        key = "-";
        action = "<cmd>Oil<CR>";
        options.desc = "Open Oil File Explorer";
      }
      {
        mode = "n";
        key = "<leader>o";
        action = "<cmd>AerialToggle!<CR>";
        options.desc = "Toggle Outline";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<CR>";
        options.desc = "Toggle Trouble Diagnostics";
      }
      {
        mode = "n";
        key = "s";
        action = config.lib.nixvim.mkRaw "function() require('flash').jump() end";
        options.desc = "Flash Jump";
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
      {
        mode = "n";
        key = "<leader>pt";
        action = "<cmd>TodoTelescope<CR>";
        options.desc = "Todo Telescope";
      }
    ] ++ lib.optionals (host == "work") [
      {
        mode = "n";
        key = "<leader>a";
        action = "<cmd>Ollama<CR>";
        options.desc = "Ollama AI Picker";
      }
      {
        mode = "v";
        key = "<leader>a";
        action = ":<C-u>Ollama<CR>";
        options.desc = "Ollama AI Picker (Visual)";
      }
      {
        mode = "n";
        key = "<leader>aa";
        action = "<cmd>AvanteChat<CR>";
        options.desc = "Avante Chat";
      }
    ];
  };
}
