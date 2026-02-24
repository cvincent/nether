{ name, mkSoftware, ... }:
mkSoftware name (
  # TODO: We need to be using a NeoVim wrapper, rather than installing gcc and
  # compiling Treesitter parsers from there. Something lightweight that still
  # allows me to helpers.directSymlink most of my configs, and keep them in raw
  # Lua, because my NeoVim config is easily my most rapidly-iterated config, so
  # I need a tight feedback loop without nixos-rebuild.

  # For now, I am simply porting over what I already have, to get through the
  # porting process.
  {
    nether,
    neovim,
    helpers,
    lib,
    pkgs,
    ...
  }:
  let
    nvr = pkgs.neovim-remote;
  in
  {
    options = {
      command = lib.mkOption {
        type = lib.types.str;
        default = "nvim";
      };

      manPager = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use NeoVim as our man pager";
      };

      nvr = lib.mkOption {
        type = lib.types.package;
        default = nvr;
      };

      scripts =
        let
          mkNeoVimScript = helpers.mkScript ./scripts;
        in
        builtins.listToAttrs [
          (mkNeoVimScript "nvr-floating-edit" {
            runtimeInputs = [ nvr ];
          })
        ];
    };

    nixos = {
      # Unlike most of our software, we install this at the system level so we
      # never have to suffer nano, in even the bleakest conditions
      environment.systemPackages = [ neovim.package ];
      nether.backups.paths."${nether.homeDirectory}/.local/share/neovim-spell".deleteMissing = true;
      nether.shells.aliases.nvs = "nvim -S Session.vim";
    };

    hm = lib.mkMerge [
      {
        xdg.configFile.nvim.source = helpers.directSymlink ./configs;

        xdg.configFile."nix-to-nvim.lua".text = ''
          return {
            lua = {
              penlight = "${pkgs.lua5_1.withPackages (ps: [ ps.penlight ])}/share/lua/5.1/?.lua";
            },
            neovim = {
              nvr_floating_edit = "${neovim.scripts.nvr-floating-edit.name}",
            },
            jj = {
              fzf_commit_ids = "${lib.getExe nether.software.jujutsu.scripts.fzf-completions}",
              split_to_bookmark = "${lib.getExe nether.software.jujutsu.scripts.jj-split-to-bookmark}",
              split_to_absorb = "${lib.getExe nether.software.jujutsu.scripts.jj-split-to-absorb}",
            },
          }
        '';

        home.packages = with pkgs; [
          # Treesitter wants a C compiler
          gcc

          # Programmatically control NeoVim
          nvr
          neovim.scripts.nvr-floating-edit

          # Image support, needed for image.nvim
          imagemagick
        ];
      }

      (lib.mkIf neovim.manPager {
        home.sessionVariables = {
          MANWIDTH = 80;
          MANPAGER = "${lib.getExe neovim.package} +Man! -c ZenMode";
          MANOPT = "--nj --nh";
        };
      })
    ];
  }
)
