{ config, pkgs, utils, ... }:

{
  # Treesitter wants a C compiler
  # Neorg wants LuaRocks which wants a non-embedded Lua install, specifically
  # 5.1. It also wants make.
  home.packages = with pkgs; [ gcc lua5_1 lua51Packages.luarocks gnumake ];
  home.file."./.config/nvim".source = utils.directSymlink "apps/nvim/configs";
  home.sessionVariables.EDITOR = "nvim";
}
