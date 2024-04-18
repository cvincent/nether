{ pkgs, our-discord, ... }:

{
  home.packages = with pkgs; [
    webcord
    our-discord.discord
    fractal
    showmethekey
  ];

  programs.zathura.enable = true;
}
