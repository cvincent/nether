{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neofetch
    bitwarden-cli
  ];
}
