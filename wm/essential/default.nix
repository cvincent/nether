{ pkgs, ... }:

{
  home.packages = with pkgs; [
    networkmanagerapplet
    polkit_gnome
    libnotify
    pavucontrol
    playerctl
    rofi
  ];
}
