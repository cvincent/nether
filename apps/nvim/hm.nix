{
  pkgs,
  nixpkgs-unstable-latest,
  utils,
  ...
}:

{
  home.packages = with pkgs; [
    # Treesitter wants a C compiler
    gcc
    # Neorg wants LuaRocks which wants a non-embedded Lua install, specifically
    # 5.1. It also wants make.
    lua5_1
    lua51Packages.luarocks
    gnumake
    # Nix formatter
    nixpkgs-unstable-latest.nixfmt-rfc-style
  ];

  home.file."./.config/nvim".source = utils.directSymlink "apps/nvim/configs";
  home.sessionVariables.EDITOR = "nvim";
}
