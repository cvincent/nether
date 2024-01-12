{ pkgs, myHomeDir, ... }:

{
  home.packages = [ (pkgs.callPackage ./pkg.nix {}) ];

  home.file."./.config/ytsub/mpv".source = ./mpv;

  home.file."./.config/ytsub/config.toml".text = ''
    video_player = "${myHomeDir}/.config/ytsub/mpv"
  '';
}
