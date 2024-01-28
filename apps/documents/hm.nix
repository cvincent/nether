{ pkgs, ... }:

{
  home.packages = with pkgs; [
    texlive.combined.scheme-medium # For generating PDFs from LaTeX
  ];
}
