{ pkgs, ... }:

{
  home.packages = with pkgs; [
    webcord
    fractal
    showmethekey
  ];

  programs.zathura.enable = true;
}
