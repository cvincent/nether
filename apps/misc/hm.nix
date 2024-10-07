{ pkgs, nixpkgs-latest, nixpkgs-unstable, our-discord, ... }:

{
  home.packages = with pkgs; [
    pkgs.webcord
    our-discord.discord
    pkgs.fractal
    pkgs.showmethekey
    pkgs.libreoffice
    pkgs.gnome.nautilus
  ];

  programs.zathura.enable = true;
}
