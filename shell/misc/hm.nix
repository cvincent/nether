{ pkgs, ... }:

{
  imports = [
    ./lf/hm.nix
  ];

  home.packages = with pkgs; [
    neofetch
    bitwarden-cli
  ];
}
