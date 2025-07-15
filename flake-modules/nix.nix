{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" = {
    options = {
      # TODO: Move this to the fish module when we get there
      nether.shells.fish.enable = lib.mkEnableOption "fish shell";
    };

    config = {
      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operator"
        ];

        optimise = {
          automatic = true;
          dates = [ "03:45" ];
        };
      };
    };
  };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      programs.nix-index = {
        enable = true;
        enableFishIntegration = osConfig.nether.shells.fish.enable;
      };
    };
}
