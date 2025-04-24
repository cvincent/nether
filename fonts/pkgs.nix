{ myFontServer, ... }:

{
  nixpkgs.config = {
    packageOverrides = super: {
      fonts.Arial = super.pkgs.callPackage ./private-font.nix {
        fontName = "Arial";
        hash = "sha256-+S2Ye5kXWNBZ2j00faYspq+io4d7qTW2NhBJooTQENo=";
        server = myFontServer;
      };
      fonts.Helvetica = super.pkgs.callPackage ./private-font.nix {
        fontName = "Helvetica";
        hash = "sha256-s7uJP0Ozt7NqcLxp6i38kCTg9KtBMJrx3qd7WnngKtM=";
        server = myFontServer;
      };
      fonts.PragmataPro = super.pkgs.callPackage ./private-font.nix {
        fontName = "PragmataPro";
        hash = "sha256-Y/7MwHpYror9kbZijm/rtCMYu2wqaYVmMvqCCrDeYEM=";
        server = myFontServer;
      };
    };
  };
}
