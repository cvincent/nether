{ pkgs, nixpkgs-latest, nixpkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    nixpkgs-unstable.discord
    nixpkgs-unstable.slack
    nixpkgs-unstable.zoom-us
    pkgs.fractal
    pkgs.showmethekey
    pkgs.libreoffice
    pkgs.gnome.nautilus
    nixpkgs-unstable.spotify
  ];

  programs.zathura.enable = true;
}
