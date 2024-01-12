{ config, pkgs, utils, ... }:

{
  home.packages = [ pkgs.swaynotificationcenter ];
  home.file."./.config/swaync".source = utils.directSymlink "wm/wayland/swaync/configs";
}
