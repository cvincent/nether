{ nixpkgs-unstable, ... }:

{
  home.packages = with nixpkgs-unstable; [
    chromium
    brave
  ];
}
