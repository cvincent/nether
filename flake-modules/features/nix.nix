{ name, mkFeature, ... }:
mkFeature name (
  { nether, inputs, ... }:
  {
    nixos.nix = {
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      settings.experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      optimise = {
        automatic = true;
        dates = [ "03:45" ];
      };
    };

    hm.programs.nix-index = {
      enable = true;
      enableFishIntegration = nether.shells.fish.enable;
    };
  }
)
