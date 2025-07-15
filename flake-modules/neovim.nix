{ name }:
{ lib, moduleWithSystem, ... }:
{
  # TODO: We need to be using a NeoVim wrapper, rather than installing gcc and
  # compiling Treesitter parsers from there. Something lightweight that still
  # allows me to utils.directSymlink most of my configs, and keep them in raw
  # Lua, because my NeoVim config is easily my most rapidly-iterated config, so
  # I need a tight feedback loop without nixos-rebuild.

  # For now, I am simply porting over what I already have, to get through the
  # porting process.

  flake.nixosModules."${name}" = {
    options = {
      nether.editors = {
        neovim.enable = lib.mkEnableOption "NeoVim - the greatest editor";

        default = lib.mkOption {
          type = lib.types.enum [
            null
            "neovim"
          ];
          default = null;
        };
      };
    };
  };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs, inputs' }:
    { osConfig, utils, ... }:
    lib.mkIf osConfig.nether.editors.neovim.enable (
      lib.mkMerge [
        {
          home.file."./.config/nvim".source = utils.directSymlink "apps/nvim/configs";

          home.packages = with pkgs; [
            # Treesitter wants a C compiler
            gcc
            # Neorg wants LuaRocks which wants a non-embedded Lua install, specifically
            # 5.1. It also wants make.
            lua5_1
            lua51Packages.luarocks
            gnumake
            nodePackages.prettier

            # Formatters
            inputs'.nixpkgs-unstable-latest.legacyPackages.nixfmt-rfc-style
            pgformatter

            # Language servers I want at all times
            nixd
            lua-language-server # The language of NeoVim
            tailwindcss-language-server
            nodePackages.typescript-language-server # TypeScript is a superset of JavaScript
            vscode-langservers-extracted # Provides VS Code's LSPs for HTML, CSS, JSON, and ESLint

            # Script NeoVim
            neovim-remote

            # Image support
            imagemagick
          ];
        }
        (lib.mkIf (osConfig.nether.editors.default == "neovim") {
          home.sessionVariables.EDITOR = "nvim";
        })
      ]
    )
  );
}
