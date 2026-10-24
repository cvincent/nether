{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    nix,
    lib,
    inputs,
    pkgInputs,
    ...
  }:
  {
    options = {
      stateVersion = lib.mkOption {
        type = lib.types.str;
      };

      langPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgInputs.nixpkgs.legacyPackages.nix;
      };
    };

    utilities = {
      nurl = { };
    };

    nixos = {
      system.stateVersion = nix.stateVersion;

      nix = {
        package = nix.langPackage;

        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];

          trusted-users = [ nether.username ];
        };

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
