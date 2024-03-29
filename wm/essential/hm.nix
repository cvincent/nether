{ pkgs, ... }:

{
  home.packages = with pkgs; [
    networkmanagerapplet
    libnotify
    pavucontrol
    playerctl
    alsa-utils
  ];

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.wlrobs ];
  };
}
