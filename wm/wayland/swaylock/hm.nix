{ nixpkgs-unstable, utils, ... }:

{
  home.packages = [ nixpkgs-unstable.swaylock ];
  home.file."./.config/swaylock/config".source = utils.directSymlink "wm/wayland/swaylock/swaylock.conf";
}
