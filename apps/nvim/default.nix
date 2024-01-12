{ config, pkgs, utils, ... }:

{
  # Treesitter wants a C compiler
  home.packages = [ pkgs.gcc ];
  home.file."./.config/nvim".source = utils.directSymlink "apps/nvim/configs";
  home.sessionVariables.EDITOR = "nvim";
}
