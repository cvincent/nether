{ name, mkFeature, ... }:
mkFeature name (
  {
    incron,
    lib,
    nether,
    ...
  }:
  {
    options = {
      userTab = lib.mkOption {
        type = lib.types.separatedString "\n";
        default = "";
      };
    };

    nixos = {
      # For some reason, defining nixpkgs.overlays from a mkSoftware results in
      # infinite recursion, but not so from mkFeature. I wish I knew why. I've
      # also tried using a top-level "nether.overlays" option to pass overlays
      # up from mkSoftware, but it still does infinite recursion. So we've
      # decided to just define incron as a top-level feature, which is fine.

      # The overlay itself is only necessary because the NixOS incron service
      # options don't provide a way to override the package, which is unusual.
      # So another approach might be to just copy the service definition into
      # our repo and make that alteration, and rename it incron-next. But I
      # think this works fine as a mkFeature.

      nixpkgs.overlays = [
        (final: prev: {
          incron = prev.incron.overrideAttrs (old: {
            src = prev.fetchFromGitHub {
              owner = "dpvpro";
              repo = "incron-next";
              rev = "master";
              hash = "sha256-mBQovW5ZY5OymgtCNRBtPSwt8g664unztDLDdprzhX4=";
            };
          });
        })
      ];

      services.incron = {
        inherit (incron) enable;
        allow = [ nether.username ];
      };

      environment.etc."incron.d/${nether.username}" = {
        mode = "0444";
        text = incron.userTab;
      };
    };
  }
)
