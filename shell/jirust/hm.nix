{ pkgs, myHomeDir, ... }:

{
  home.packages = [ (pkgs.callPackage ./pkg.nix {}) ];
}
