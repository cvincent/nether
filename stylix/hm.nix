{ inputs, ... }:

{
  imports = [
    inputs.stylix.homeManagerModules.stylix
    ./common.nix
  ];
}
