{ pkgs, ... }:

{
  imports = [ ./pkgs.nix ];

  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    packages = with pkgs; [
      fonts.Arial
      fonts.Helvetica
      fonts.PragmataPro
    ];
  };
}
