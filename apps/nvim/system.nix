{ inputs, nixpkgs-unstable-latest, ... }:

{
  # Not sure if this needs to be installed at the system level, test later
  environment.systemPackages = [ nixpkgs-unstable-latest.nixd ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}
