{ pkgs, nixpkgs-unstable-latest, ... }:

{
  imports = [
    ./lf/hm.nix
  ];

  home.packages = with pkgs; [
    neofetch
    bitwarden-cli
    nixpkgs-unstable-latest.gh
  ];
}
