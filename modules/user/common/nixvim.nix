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

  home.packages = [ pkgs.lazygit ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    luaLoader.enable = true;

    # ───── Options ─────
    opts = {
      number = true;
      relativenumber = true;
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
      splitbelow = true;
      splitright = true;
      conceallevel = 2;
      pumheight = 10;
      timeoutlen = 300;
      list = true;
      listchars = "tab:» ,trail:·,nbsp:␣";
    };

    # ───── Colorscheme ─────
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = false;
        term_colors = true;
        integrations = {
          bufferline = true;
          diffview = true;
          gitsigns = true;
          harpoon = true;
          neotree = true;
          noice = true;
          notify = true;
          render_markdown = true;
          treesitter = true;
          which_key = true;
          lsp_trouble = true;
          telescope.enabled = true;
        };
      };
    };

    # ───── UI & Aesthetics ─────
    plugins.web-devicons.enable = true;

    plugins.lualine = {
      enable = true;
      settings.options = {
        theme = "auto";
        section_separators = { left = ""; right = ""; };
        component_separators = { left = ""; right = ""; };
      };
    };

    plugins.bufferline = {
      enable = true;
      settings.options = {
        separator_style = "slant";
        show_buffer_close_icons = true;
        show_close_icon = false;
        offsets = [
          {
            filetype = "neo-tree";
            text = "  EXPLORER";
            highlight = "Directory";
            text_align = "left";
          }
        ];
      };
    };

    plugins.barbecue.enable = true;

    plugins.neoscroll.enable = true;
    plugins.colorizer.enable = true;
    plugins.dressing.enable = true;

    plugins.toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        open_mapping = "[[<C-t>]]";
        float_opts.border = "curved";
      };
    };

    plugins.notify = {
      enable = true;
      settings = {
        background_colour = "#1e1e2e";
        render = "wrapped-compact";
        timeout = 3000;
        top_down = false;
      };
    };

    # Fixed: add presets to prevent input errors (especially / search)
    plugins.noice = {
      enable = true;
      settings = {
        cmdline.enabled = true;
        messages.enabled = true;
        popupmenu.enabled = true;
        notify.enabled = true;
        lsp = {
          progress.enabled = false; # fidget handles this
          hover.enabled = true;
          signature.enabled = true;
          message.enabled = true;
        };
        presets = {
          bottom_search = true;        # classic bottom cmdline for search (fixes input errors)
          command_palette = true;      # cmdline + popupmenu together
          long_message_to_split = true;
          inc_rename = false;
          lsp_doc_border = true;       # border on hover/signature
        };
        routes = [
          {
            filter = {
              event = "msg_show";
              kind = "";
              find = "written";
            };
            opts.skip = true;
          }
        ];
      };
    };

    # LSP progress indicator (noice lsp.progress disabled above)
    plugins.fidget = {
      enable = true;
      settings = {
        notification.window = {
          winblend = 0;
          border = "none";
        };
        progress.display.done_icon = "✓";
      };
    };

    plugins.alpha = {
      enable = true;
      theme = "dashboard";
    };

    # Session management
    plugins.persistence.enable = true;

    # ───── Syntax & Code Structure ─────
    plugins.treesitter = {
      enable = true;
      settings = {
        indent.enable = true;
        highlight.enable = true;
        incremental_selection.enable = true;
      };
    };

    plugins.treesitter-context = {
      enable = true;
      settings.max_lines = 3;
    };

    plugins.indent-blankline = {
      enable = true;
      settings = {
        scope.enabled = true;
        indent.char = "│";
      };
    };

    plugins.render-markdown = {
      enable = true;
      settings = {
        file_types = ["markdown" "Avante"];
        code = {
          sign = false;
          width = "block";
          right_pad = 1;
        };
        heading.icons = ["󰲡 " "󰲣 " "󰲥 " "󰲧 " "󰲩 " "󰲫 "];
      };
    };

    # ───── Navigation ─────
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
        float.border = "rounded";
      };
    };

    plugins.harpoon = {
      enable = true;
      enableTelescope = true;
    };

    plugins.todo-comments.enable = true;

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

    # ───── Git Integration ─────
    plugins.gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        current_line_blame_opts.delay = 500;
        signs = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
          untracked.text = "▎";
        };
      };
    };

    plugins.diffview.enable = true;

    # ───── Diagnostics ─────
    plugins.trouble = {
      enable = true;
      settings.auto_close = true;
    };

    # ───── Debugger ─────
    plugins.dap = {
      enable = true;
      signs = {
        dapBreakpoint.text = "";
        dapBreakpointCondition.text = "";
        dapLogPoint.text = "󰆿";
        dapStopped.text = "";
        dapBreakpointRejected.text = "";
      };
    };

    plugins.dap-ui = {
      enable = true;
      settings = {
        icons = { expanded = ""; collapsed = ""; current_frame = ""; };
        layouts = [
          {
            elements = [
              { id = "scopes"; size = 0.4; }
              { id = "breakpoints"; size = 0.15; }
              { id = "stacks"; size = 0.25; }
              { id = "watches"; size = 0.2; }
            ];
            position = "left";
            size = 40;
          }
          {
            elements = [
              { id = "repl"; size = 0.5; }
              { id = "console"; size = 0.5; }
            ];
            position = "bottom";
            size = 12;
          }
        ];
      };
    };

    plugins.dap-virtual-text = {
      enable = true;
      settings = {
        enabled = true;
        highlight_changed_variables = true;
        all_frames = false;
      };
    };

    # ───── Search & Replace ─────
    plugins.grug-far = {
      enable = true;
      settings.prefills.flags = "--pcre2";
    };

    # ───── Formatting ─────
    # Fixed: lsp_fallback (deprecated) → lsp_format = "fallback"
    plugins.conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_format = "fallback";
          timeout_ms = 500;
        };
        formatters_by_ft = {
          nix = ["nixfmt"];
          python = ["black"];
          javascript = ["prettierd" "prettier"];
          typescript = ["prettierd" "prettier"];
          html = ["prettierd" "prettier"];
          css = ["prettierd" "prettier"];
          json = ["prettierd"];
          yaml = ["prettierd"];
          markdown = ["prettierd"];
          lua = ["stylua"];
        };
      };
    };

    # ───── File Explorer ─────
    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        popup_border_style = "rounded";
        enable_git_status = true;
        enable_diagnostics = true;
        sources = [ "filesystem" "buffers" "git_status" ];
        source_selector = {
          winbar = true;
          content_layout = "center";
          sources = [
            { source = "filesystem"; display_name = " 󰉓 Files "; }
            { source = "buffers"; display_name = " 󰈚 Buffers "; }
            { source = "git_status"; display_name = " 󰊢 Git "; }
          ];
        };
        window = {
          width = 35;
          mappings = {
            "l" = "open";
            "h" = "close_node";
            "<Right>" = "open";
            "<Left>" = "close_node";
            "H" = "toggle_hidden";
            "<space>" = "none";
            "Y" = {
              __raw = ''
                function(state)
                  local node = state.tree:get_node()
                  local path = node:get_id()
                  vim.fn.setreg("+", path, "c")
                end
              '';
              desc = "copy path to clipboard";
            };
          };
        };
        default_component_configs = {
          indent = {
            indent_size = 2;
            padding = 1;
            with_markers = true;
            indent_marker = "│";
            last_indent_marker = "└";
            highlight = "NeoTreeIndentMarker";
          };
          icon = {
            folder_closed = "";
            folder_open = "";
            folder_empty = "󰜔";
            default = "󰈙";
            highlight = "NeoTreeFileIcon";
          };
          modified = {
            symbol = "●";
            highlight = "NeoTreeModified";
          };
          name = {
            trailing_slash = false;
            use_git_status_colors = true;
            highlight = "NeoTreeFileName";
          };
          git_status = {
            symbols = {
              added = "✚";
              modified = "";
              deleted = "✖";
              renamed = "󰁕";
              untracked = "";
              ignored = "";
              unstaged = "󰄱";
              staged = "";
              conflict = "";
            };
          };
          diagnostics = {
            symbols = {
              error = " ";
              warn = " ";
              info = " ";
              hint = "󰌵";
            };
          };
        };
        filesystem = {
          bind_to_cwd = false;
          follow_current_file = { enabled = true; };
          use_libuv_file_watcher = true;
          filtered_items = {
            visible = false;
            hide_dotfiles = false;
            hide_gitignored = true;
            hide_by_name = [".git" "node_modules" ".direnv"];
          };
        };
      };
    };

    # ───── Fuzzy Finder ─────
    plugins.telescope = {
      enable = true;
      settings.defaults = {
        file_ignore_patterns = ["node_modules" ".git/" "dist/" ".direnv/"];
        layout_strategy = "horizontal";
        sorting_strategy = "ascending";
        layout_config.prompt_position = "top";
      };
      extensions = {
        fzf-native.enable = true;
      };
    };

    # ───── Undo History ─────
    plugins.undotree = {
      enable = true;
      settings = {
        focusOnToggle = true;
        WindowLayout = 2;
      };
    };

    # ───── LSP ─────
    plugins.lazydev = {
      enable = true;
      settings.library = [
        { path = "luvit-meta/library"; words = ["vim%.uv"]; }
      ];
    };

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
        lua_ls.enable = true;
        cssls.enable = true;
        jsonls.enable = true;
      };
      keymaps = {
        lspBuf = {
          K = "hover";
          gD = "references";
          gd = "definition";
          gi = "implementation";
          gt = "type_definition";
          "<leader>ca" = "code_action";
          "<leader>rn" = "rename";
        };
        diagnostic = {
          "<leader>df" = "open_float";
          "[d" = "goto_prev";
          "]d" = "goto_next";
        };
      };
    };

    # ───── Completion ─────
    plugins.blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "default";
          "<Tab>" = ["select_next" "fallback"];
          "<S-Tab>" = ["select_prev" "fallback"];
        };
        appearance = {
          nerd_font_variant = "mono";
        };
        completion = {
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          ghost_text.enabled = host != "work";
          menu.border = "rounded";
        };
        signature = {
          enabled = true;
          window.border = "rounded";
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

    # ───── AI: Avante (local chat via Ollama) ─────
    # Avante is used only in local mode; in cloud mode Claude Code
    # (claudecode-nvim) is the primary AI chat. Uses the native Ollama
    # provider (/api/chat) instead of OpenAI-compat so Qwen thinking
    # tokens are handled correctly.
    plugins.avante = {
      enable = host == "work";
      settings = {
        provider = "ollama";
        auto_suggestions_provider = "ollama";
        behaviour = {
          auto_suggestions = false;
          auto_set_highlight_group = true;
          auto_set_keymaps = true;
          auto_apply_diff_after_generation = false;
          support_paste_from_clipboard = true;
        };
        vendors = {
          ollama = {
            __inherited_from = "ollama";
            api_key_name = "";
            endpoint = "http://127.0.0.1:11434";
            model = "qwen2.5-coder:32b";
            timeout = 60000;
            keep_alive = "30m";
            is_env_set = config.lib.nixvim.mkRaw "function() return true end";
          };
        };
      };
    };

    # ───── AI: Ollama (Work only) ─────
    # Disabled: ollama.nvim has a crash bug (start_col > end_col in nvim_buf_get_text)
    plugins.ollama = {
      enable = false;
      settings = {
        model = "qwen3:30b-a3b";
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

    # ───── AI: Claude Code ─────
    extraPlugins = [ pkgs.vimPlugins.claudecode-nvim ];

    # ───── AI: Minuet Ghost Text (Work only) ─────
    plugins.minuet = {
      enable = host == "work";
      settings = {
        provider = "openai_fim_compatible";
        provider_options = {
          openai_fim_compatible = {
            model = "deepseek-coder-v2:16b";
            end_point = "http://127.0.0.1:11434/v1/completions";
            name = "ollama";
            api_key = "TERM";
          };
          claude = {
            model = "claude-haiku-4-5-20251001";
            api_key = "ANTHROPIC_API_KEY";
            max_tokens = 512;
          };
        };
        virtualtext.auto_trigger_ft = [];
        request_timeout = 3;
        throttle = 1500;
        notify_on_error = false;
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

    # ───── Utility Plugins ─────
    plugins.comment.enable = true;
    plugins.nvim-autopairs.enable = true;
    plugins.nvim-surround.enable = true; # replaces vim-surround (modern, more features)
    plugins.which-key = {
      enable = true;
      settings.spec = [
        { __unkeyed-1 = "<leader>p"; group = "Telescope"; icon = ""; }
        { __unkeyed-1 = "<leader>a"; group = "AI"; icon = "󰚩"; }
        { __unkeyed-1 = "<leader>x"; group = "Diagnostics"; icon = ""; }
        { __unkeyed-1 = "<leader>h"; group = "Harpoon"; icon = "󰛢"; }
        { __unkeyed-1 = "<leader>g"; group = "Git"; icon = ""; }
        { __unkeyed-1 = "<leader>s"; group = "Search"; icon = "󰍉"; }
        { __unkeyed-1 = "<leader>d"; group = "LSP/Debug"; icon = ""; }
        { __unkeyed-1 = "<leader>q"; group = "Session"; icon = ""; }
        { __unkeyed-1 = "<leader>b"; group = "Buffer"; icon = ""; }
        { __unkeyed-1 = "g"; group = "Goto"; icon = ""; }
        { __unkeyed-1 = "]"; group = "Next"; icon = ""; }
        { __unkeyed-1 = "["; group = "Prev"; icon = ""; }
      ];
    };

    # ───── Extra Lua ─────
    extraConfigLua = ''
      -- Claude Code
      require("claudecode").setup({
        split_side = "right",
        split_width_percentage = 0.38,
        auto_close_on_leave = false,
      })

      -- DAP UI auto-open/close
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Java DAP via jdtls
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug: Attach to Process",
          hostName = "localhost",
          port = 5005,
        },
        {
          type = "java",
          request = "launch",
          name = "Debug: Launch Current File",
          mainClass = function()
            return vim.fn.input("Main class: ", vim.fn.expand("%:r"):gsub("/", "."):gsub("src%.main%.java%.", ""))
          end,
        },
      }

      -- Clear search highlight with Escape
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

      -- Better diagnostics display
      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 4 },
        float = { border = "rounded", source = "always" },
        signs = true,
        underline = true,
        severity_sort = true,
        update_in_insert = false,
      })

      -- Diagnostic signs (nerd font icons)
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Lazygit
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = { border = "curved" },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
        end,
      })
      function _LAZYGIT_TOGGLE() lazygit:toggle() end
    '' + lib.optionalString (host == "work") ''
      -- AI Mode Toggle
      --   Local:  Avante (Ollama qwen3)        + Minuet (Ollama deepseek-coder)
      --   Cloud:  Claude Code (claudecode-nvim) + Minuet (Claude haiku)
      -- In cloud mode Avante is NOT used — use <leader>ac for Claude Code
      -- in the right split instead.
      local _ai_mode = "local"
      function _AI_TOGGLE()
        local minuet = require("minuet")
        if _ai_mode == "local" then
          _ai_mode = "cloud"
          minuet.config.provider = "claude"
          vim.notify("AI: Cloud ☁️  — Claude Code (<leader>ac) + Minuet/Claude", vim.log.levels.INFO)
        else
          _ai_mode = "local"
          minuet.config.provider = "openai_fim_compatible"
          vim.notify("AI: Lokal 🦙 — Avante/Ollama (<leader>aa) + Minuet/Ollama", vim.log.levels.INFO)
        end
      end

      function _AI_STATUS()
        vim.notify("AI Mode: " .. _ai_mode, vim.log.levels.INFO)
      end
    '';

    # ───── Keymaps ─────
    globals.mapleader = " ";

    keymaps = [
      # File Explorer
      { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<CR>"; options.desc = "Toggle File Explorer"; }
      { mode = "n"; key = "-"; action = "<cmd>Oil<CR>"; options.desc = "Open Oil"; }

      # Symbol Outline
      { mode = "n"; key = "<leader>o"; action = "<cmd>AerialToggle!<CR>"; options.desc = "Toggle Outline"; }

      # Diagnostics / Trouble
      { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<CR>"; options.desc = "Toggle All Diagnostics"; }
      { mode = "n"; key = "<leader>xd"; action = "<cmd>Trouble document_diagnostics toggle<CR>"; options.desc = "Document Diagnostics"; }
      { mode = "n"; key = "<leader>xq"; action = "<cmd>Trouble quickfix toggle<CR>"; options.desc = "Quickfix List"; }

      # Flash Jump
      { mode = "n"; key = "s"; action = config.lib.nixvim.mkRaw "function() require('flash').jump() end"; options.desc = "Flash Jump"; }
      { mode = ["n" "x" "o"]; key = "S"; action = config.lib.nixvim.mkRaw "function() require('flash').treesitter() end"; options.desc = "Flash Treesitter"; }

      # Save
      { mode = "n"; key = "<C-s>"; action = "<cmd>w<CR>"; options.desc = "Save File"; }
      { mode = "i"; key = "<C-s>"; action = "<cmd>w<CR><Esc>"; options.desc = "Save File"; }

      # Move Lines
      { mode = "n"; key = "<A-j>"; action = "<cmd>m .+1<CR>=="; options.desc = "Move Line Down"; }
      { mode = "n"; key = "<A-k>"; action = "<cmd>m .-2<CR>=="; options.desc = "Move Line Up"; }
      { mode = "v"; key = "<A-j>"; action = ":m '>+1<CR>gv=gv"; options = { desc = "Move Selection Down"; silent = true; }; }
      { mode = "v"; key = "<A-k>"; action = ":m '<-2<CR>gv=gv"; options = { desc = "Move Selection Up"; silent = true; }; }

      # Visual indent (stay in visual mode)
      { mode = "v"; key = "<"; action = "<gv"; options.desc = "Indent Left"; }
      { mode = "v"; key = ">"; action = ">gv"; options.desc = "Indent Right"; }

      # Centered scroll
      { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; options.desc = "Scroll Down Centered"; }
      { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; options.desc = "Scroll Up Centered"; }

      # Yank to system clipboard
      { mode = ["n" "v"]; key = "<leader>y"; action = "\"+y"; options.desc = "Yank to Clipboard"; }

      # Window Navigation
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move Left"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move Down"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move Up"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move Right"; }

      # Window Resize
      { mode = "n"; key = "<C-Up>"; action = "<cmd>resize +2<CR>"; options.desc = "Increase Height"; }
      { mode = "n"; key = "<C-Down>"; action = "<cmd>resize -2<CR>"; options.desc = "Decrease Height"; }
      { mode = "n"; key = "<C-Left>"; action = "<cmd>vertical resize -2<CR>"; options.desc = "Decrease Width"; }
      { mode = "n"; key = "<C-Right>"; action = "<cmd>vertical resize +2<CR>"; options.desc = "Increase Width"; }

      # Buffer Navigation
      { mode = "n"; key = "<S-h>"; action = "<cmd>bprevious<CR>"; options.desc = "Previous Buffer"; }
      { mode = "n"; key = "<S-l>"; action = "<cmd>bnext<CR>"; options.desc = "Next Buffer"; }
      { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<CR>"; options.desc = "Close Buffer"; }
      { mode = "n"; key = "<leader>bo"; action = "<cmd>%bdelete|edit#|bdelete#<CR>"; options.desc = "Close Other Buffers"; }

      # Better j/k with wrapped lines
      { mode = ["n" "x"]; key = "j"; action = "v:count == 0 ? 'gj' : 'j'"; options = { desc = "Down"; expr = true; silent = true; }; }
      { mode = ["n" "x"]; key = "k"; action = "v:count == 0 ? 'gk' : 'k'"; options = { desc = "Up"; expr = true; silent = true; }; }

      # Telescope
      { mode = "n"; key = "<leader>pf"; action = "<cmd>Telescope find_files<CR>"; options.desc = "Find Files"; }
      { mode = "n"; key = "<leader>ps"; action = "<cmd>Telescope live_grep<CR>"; options.desc = "Live Grep"; }
      { mode = "n"; key = "<leader>pb"; action = "<cmd>Telescope buffers<CR>"; options.desc = "Buffers"; }
      { mode = "n"; key = "<leader>ph"; action = "<cmd>Telescope help_tags<CR>"; options.desc = "Help Tags"; }
      { mode = "n"; key = "<leader>pr"; action = "<cmd>Telescope oldfiles<CR>"; options.desc = "Recent Files"; }
      { mode = "n"; key = "<leader>pt"; action = "<cmd>TodoTelescope<CR>"; options.desc = "Todo Comments"; }
      { mode = "n"; key = "<leader>pp"; action = "<cmd>Telescope harpoon marks<CR>"; options.desc = "Harpoon Marks"; }

      # Search & Replace
      { mode = "n"; key = "<leader>sr"; action = "<cmd>GrugFar<CR>"; options.desc = "Search & Replace (GrugFar)"; }
      { mode = "n"; key = "<leader>sw"; action = "<cmd>Telescope grep_string<CR>"; options.desc = "Grep Word Under Cursor"; }

      # Undo Tree
      { mode = "n"; key = "<leader>u"; action = "<cmd>UndotreeToggle<CR>"; options.desc = "Toggle Undo Tree"; }

      # Git
      { mode = "n"; key = "<leader>gg"; action = config.lib.nixvim.mkRaw "function() _LAZYGIT_TOGGLE() end"; options.desc = "Lazygit"; }
      { mode = "n"; key = "<leader>gd"; action = "<cmd>DiffviewOpen<CR>"; options.desc = "Diff View"; }
      { mode = "n"; key = "<leader>gh"; action = "<cmd>DiffviewFileHistory %<CR>"; options.desc = "File History"; }
      { mode = "n"; key = "<leader>gs"; action = config.lib.nixvim.mkRaw "function() require('gitsigns').stage_hunk() end"; options.desc = "Stage Hunk"; }
      { mode = "v"; key = "<leader>gs"; action = config.lib.nixvim.mkRaw "function() require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end"; options.desc = "Stage Hunk"; }
      { mode = "n"; key = "<leader>gr"; action = config.lib.nixvim.mkRaw "function() require('gitsigns').reset_hunk() end"; options.desc = "Reset Hunk"; }
      { mode = "n"; key = "<leader>gS"; action = config.lib.nixvim.mkRaw "function() require('gitsigns').stage_buffer() end"; options.desc = "Stage Buffer"; }
      { mode = "n"; key = "<leader>gp"; action = config.lib.nixvim.mkRaw "function() require('gitsigns').preview_hunk() end"; options.desc = "Preview Hunk"; }
      { mode = "n"; key = "<leader>gb"; action = config.lib.nixvim.mkRaw "function() require('gitsigns').blame_line({ full = true }) end"; options.desc = "Blame Line (full)"; }
      { mode = "n"; key = "]h"; action = config.lib.nixvim.mkRaw "function() require('gitsigns').nav_hunk('next') end"; options.desc = "Next Hunk"; }
      { mode = "n"; key = "[h"; action = config.lib.nixvim.mkRaw "function() require('gitsigns').nav_hunk('prev') end"; options.desc = "Prev Hunk"; }

      # Session
      { mode = "n"; key = "<leader>qs"; action = config.lib.nixvim.mkRaw "function() require('persistence').load() end"; options.desc = "Restore Session"; }
      { mode = "n"; key = "<leader>ql"; action = config.lib.nixvim.mkRaw "function() require('persistence').load({ last = true }) end"; options.desc = "Restore Last Session"; }

      # Harpoon
      { mode = "n"; key = "<leader>ha"; action = config.lib.nixvim.mkRaw "function() require('harpoon'):list():add() end"; options.desc = "Harpoon Add File"; }
      { mode = "n"; key = "<leader>hh"; action = config.lib.nixvim.mkRaw "function() local h = require('harpoon'); h.ui:toggle_quick_menu(h:list()) end"; options.desc = "Harpoon Menu"; }
      { mode = "n"; key = "<leader>1"; action = config.lib.nixvim.mkRaw "function() require('harpoon'):list():select(1) end"; options.desc = "Harpoon File 1"; }
      { mode = "n"; key = "<leader>2"; action = config.lib.nixvim.mkRaw "function() require('harpoon'):list():select(2) end"; options.desc = "Harpoon File 2"; }
      { mode = "n"; key = "<leader>3"; action = config.lib.nixvim.mkRaw "function() require('harpoon'):list():select(3) end"; options.desc = "Harpoon File 3"; }
      { mode = "n"; key = "<leader>4"; action = config.lib.nixvim.mkRaw "function() require('harpoon'):list():select(4) end"; options.desc = "Harpoon File 4"; }

      # Debugger (DAP)
      { mode = "n"; key = "<F5>"; action = config.lib.nixvim.mkRaw "function() require('dap').continue() end"; options.desc = "DAP: Continue"; }
      { mode = "n"; key = "<F10>"; action = config.lib.nixvim.mkRaw "function() require('dap').step_over() end"; options.desc = "DAP: Step Over"; }
      { mode = "n"; key = "<F11>"; action = config.lib.nixvim.mkRaw "function() require('dap').step_into() end"; options.desc = "DAP: Step Into"; }
      { mode = "n"; key = "<F12>"; action = config.lib.nixvim.mkRaw "function() require('dap').step_out() end"; options.desc = "DAP: Step Out"; }
      { mode = "n"; key = "<leader>db"; action = config.lib.nixvim.mkRaw "function() require('dap').toggle_breakpoint() end"; options.desc = "Toggle Breakpoint"; }
      { mode = "n"; key = "<leader>dB"; action = config.lib.nixvim.mkRaw "function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end"; options.desc = "Conditional Breakpoint"; }
      { mode = "n"; key = "<leader>dc"; action = config.lib.nixvim.mkRaw "function() require('dap').continue() end"; options.desc = "DAP: Continue/Start"; }
      { mode = "n"; key = "<leader>dt"; action = config.lib.nixvim.mkRaw "function() require('dap').terminate() end"; options.desc = "DAP: Terminate"; }
      { mode = "n"; key = "<leader>du"; action = config.lib.nixvim.mkRaw "function() require('dapui').toggle() end"; options.desc = "DAP UI Toggle"; }
      { mode = "n"; key = "<leader>dr"; action = config.lib.nixvim.mkRaw "function() require('dap').repl.open() end"; options.desc = "DAP REPL"; }
      { mode = ["n" "v"]; key = "<leader>dh"; action = config.lib.nixvim.mkRaw "function() require('dap.ui.widgets').hover() end"; options.desc = "DAP Hover Variable"; }

      # Claude Code (cloud chat — primary AI chat in cloud mode)
      { mode = "n"; key = "<leader>ac"; action = "<cmd>ClaudeCode<CR>"; options.desc = "Claude Code Toggle"; }
      { mode = ["n" "v"]; key = "<leader>as"; action = "<cmd>ClaudeCodeSend<CR>"; options.desc = "Claude Code Send"; }
      { mode = "n"; key = "<leader>af"; action = "<cmd>ClaudeCodeFocus<CR>"; options.desc = "Claude Code Focus"; }
    ] ++ lib.optionals (host == "work") [
      # Avante (local chat — Ollama)
      { mode = "n"; key = "<leader>aa"; action = "<cmd>AvanteAsk<CR>"; options.desc = "Avante Ask (Ollama)"; }
      { mode = "n"; key = "<leader>at"; action = "<cmd>AvanteToggle<CR>"; options.desc = "Avante Toggle (Ollama)"; }

      # Minuet Ghost Text (Line-Completion)
      { mode = "i"; key = "<A-y>"; action = config.lib.nixvim.mkRaw "function() require('minuet.virtualtext').action.accept() end"; options.desc = "Minuet Accept"; }
      { mode = "i"; key = "<A-n>"; action = config.lib.nixvim.mkRaw "function() require('minuet.virtualtext').action.next() end"; options.desc = "Minuet Next"; }
      { mode = "i"; key = "<A-p>"; action = config.lib.nixvim.mkRaw "function() require('minuet.virtualtext').action.prev() end"; options.desc = "Minuet Prev"; }
      { mode = "i"; key = "<A-x>"; action = config.lib.nixvim.mkRaw "function() require('minuet.virtualtext').action.dismiss() end"; options.desc = "Minuet Dismiss"; }

      # AI Mode Toggle
      { mode = "n"; key = "<leader>am"; action = config.lib.nixvim.mkRaw "function() _AI_TOGGLE() end"; options.desc = "Toggle AI: Lokal/Cloud"; }
      { mode = "n"; key = "<leader>aM"; action = config.lib.nixvim.mkRaw "function() _AI_STATUS() end"; options.desc = "Show AI Mode"; }
    ];
  };
}
