{ pkgs, ... }:

{
  home.packages = with pkgs; [
    webcord
    fractal
    showmethekey
    godot_4
  ];

  programs.zathura.enable = true;
}
