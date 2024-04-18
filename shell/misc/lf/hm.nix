{ pkgs, ... }:

{
  home.packages = [
    pkgs.file
  ];

  programs.lf = {
    enable = true;
    settings = {
      previewer = "~/.config/lf/previewer-kitty";
    };
  };

  home.file."./.config/lf/previewer-kitty".source = ./previewer-kitty;
}
