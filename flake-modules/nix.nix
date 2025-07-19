{ name }:
{ inputs, ... }:
{
  flake.nixosModules."${name}" = {
    config = {
      nix = {
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

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
