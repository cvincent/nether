{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    nix,
    lib,
    inputs,
    ...
  }:
  {
    options.stateVersion = lib.mkOption {
      type = lib.types.str;
    };

    nixos = {
      system.stateVersion = nix.stateVersion;

      nix = {
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
    };

    hm = {
      home.stateVersion = nix.stateVersion;

      programs.nix-index = {
        enable = true;
        enableFishIntegration = nether.shells.fish.enable;
      };
    };
  }
)
