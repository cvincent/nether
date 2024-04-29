{ config, pkgs, utils, nixpkgs-unstable, ... }:

{
  programs.ncspot = {
    enable = true;
    package = nixpkgs-unstable.ncspot;
  };
}
