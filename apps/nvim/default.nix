{
  config,
  inputs,
  lib,
}:

let
  cfg = config.apps.nvim;
in
{
  options.apps.nvim = {
    enable = lib.mkEnableOption "NeoVim";
  };

  config = lib.mkIf cfg.enable {
    nixosConfigurations.revachol = lib.nixosSystem {
      environment.systemPackages = [ inputs.nixpkgs-unstable-latest.nixd ];
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    };

    homeConfigurations.cvincent = inputs.home-manager.lib.homeManagerConfiguration {
      home.packages = with inputs.nixpkgs.pkgs; [
        # Treesitter wants a C compiler
        gcc
        # Neorg wants LuaRocks which wants a non-embedded Lua install, specifically
        # 5.1. It also wants make.
        lua5_1
        lua51Packages.luarocks
        gnumake
        nodePackages.prettier

        # Formatters
        nixpkgs-unstable-latest.nixfmt-rfc-style
        pgformatter

        # Language servers I want at all times
        lua-language-server # The language of NeoVim
        tailwindcss-language-server
        nodePackages.typescript-language-server # TypeScript is a superset of JavaScript
        vscode-langservers-extracted # Provides VS Code's LSPs for HTML, CSS, JSON, and ESLint

        # Script NeoVim
        neovim-remote

        # Image support
        imagemagick
      ];

      home.file."./.config/nvim".source = (import ../utils).directSymlink "apps/nvim/configs";
      home.sessionVariables.EDITOR = "nvim";
    };
  };
}
