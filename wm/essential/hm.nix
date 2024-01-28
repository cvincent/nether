{ pkgs, ... }:

{
  home.packages = with pkgs; [
    networkmanagerapplet
    libnotify
    pavucontrol
    playerctl
    alsa-utils
  ];
}
