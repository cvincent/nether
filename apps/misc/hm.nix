{ pkgs, our-discord, ... }:

{
  home.packages = with pkgs; [
    webcord
    our-discord.discord
    fractal
    showmethekey
    libreoffice
    gnome.nautilus
  ];

  programs.zathura.enable = true;
}
