{ inputs, nixpkgs-unstable-latest, ... }:

{
  environment.systemPackages = [ nixpkgs-unstable-latest.nixd ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}
