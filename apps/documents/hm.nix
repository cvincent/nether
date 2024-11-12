{ pkgs, ... }:

{
  home.packages = with pkgs; [
    texlive.combined.scheme-medium # For generating PDFs from LaTeX
    d2 # Text to diagrams

    (pkgs.writeShellScriptBin "generate-invoice" (builtins.readFile ./generate-invoice.bash))
  ];
}
