{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = {
    options.nether.scripts.invoiceGenerator.enable =
      lib.mkEnableOption "Script for generating and sending invoices";
  };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    {
      # TODO: Get rid of this or wrap it properly with writeShellApplication
      config = lib.mkIf osConfig.nether.scripts.invoiceGenerator.enable {
        home.packages = with pkgs; [
          texlive.combined.scheme-medium # For generating PDFs from LaTeX
          (pkgs.writeShellScriptBin "generate-invoice" (builtins.readFile ./generate-invoice.bash))
        ];
      };
    }
  );
}
