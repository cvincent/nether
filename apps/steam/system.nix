{ nixpkgs-unstable-latest, ... }:

{
  programs.steam.enable = true;
  environment.systemPackages = [
    nixpkgs-unstable-latest.protonup-qt
    nixpkgs-unstable-latest.protontricks
  ];
}
