{ pkgs, utils, ... }:

{
  home.packages = with pkgs; [ swaylock ];
  home.file."./.config/swaylock/config".source = utils.directSymlink "wm/wayland/swaylock/swaylock.conf";
}
