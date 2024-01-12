{ pkgs, mySopsKey, ... }:

{
  nixpkgs.config = {
    packageOverrides = super: {
      fonts.Arial = super.pkgs.callPackage ./encrypted-font.nix {
        key = mySopsKey;
        name = "Arial";
      };
      fonts.Helvetica = super.pkgs.callPackage ./encrypted-font.nix {
        key = mySopsKey;
        name = "Helvetica";
      };
      fonts.PragmataPro = super.pkgs.callPackage ./encrypted-font.nix {
        key = mySopsKey;
        name = "PragmataPro";
      };
    };
  };
}
