{ pkgs, ... }:

{
  home.packages = with pkgs; [
    webcord
    fractal
  ];

  programs.zathura.enable = true;
}
