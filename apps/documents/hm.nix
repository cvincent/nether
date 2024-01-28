{ pkgs, ... }:

{
  home.packages = with pkgs; [
    texlive.combined.scheme-medium # For generating PDFs from LaTeX

    (pkgs.writeShellScriptBin "generate-invoice" (builtins.readFile ./generate-invoice.bash))
  ];
}
