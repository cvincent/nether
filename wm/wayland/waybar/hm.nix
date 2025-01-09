{ pkgs, utils, ... }:

{
  home.packages = [ pkgs.waybar ];
  home.file."./.config/waybar".source = utils.directSymlink "wm/wayland/waybar/configs";
}
