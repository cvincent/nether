{ config, pkgs, utils, ... }:

{
  home.packages = with pkgs; [
    mpv
    yt-dlp
  ];
  home.file.".config/mpv".source = utils.directSymlink "apps/mpv/configs";
}
