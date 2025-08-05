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
    pkgs,
    pkgInputs,
    ...
  }:
  {
    nixos = {
      # Unlike most of our software, we install this at the system level so we
      # never have to suffer nano, in even the bleakest conditionsb
      environment.systemPackages = [ neovim.package ];
      nether.backups.paths."${nether.homeDirectory}/.local/share/neovim-spell".deleteMissing = true;
      nether.shells.aliases.nvs = "nvim -S Session.vim";
    };

    hm = {
      home.file."./.config/nvim".source = helpers.directSymlink ./configs;

      home.packages = with pkgs; [
        # Treesitter wants a C compiler
        gcc

        # Programmatically control NeoVim
        neovim-remote

        # Image support, needed for image.nvim
        imagemagick
      ];
    };
  }
)
