{ pkgs, ... }:

{
  imports = [
    ./lf/hm.nix
  ];

  programs.gh.enable = true;

  home.packages = with pkgs; [
    neofetch
    bitwarden-cli
  ];
}
