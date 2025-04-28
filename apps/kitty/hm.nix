{ nixpkgs-kitty, utils, ... }:

{
  home.packages = [ nixpkgs-kitty.kitty ];
  home.file."./.config/kitty/kitty.conf".source = utils.directSymlink "apps/kitty/configs/kitty.conf";
  home.file."./.config/kitty/nord.conf".source = utils.directSymlink "apps/kitty/configs/nord.conf";
}
