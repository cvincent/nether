{ name, mkSoftware, ... }:
mkSoftware name (
  {
    nether,
    chromium,
    lib,
    ...
  }:
  {
    options.commandLineArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    nixos = {
      nether.backups.paths."${nether.homeDirectory}/.config/chromium".deleteMissing = true;

      # Silences warnings on Chromium boot, and useful for checking battery
      # levels from CLI
      services.upower.enable = true;
    };

    hm = {
      programs.chromium = {
        enable = true;
        package = chromium.package.override { inherit (chromium) commandLineArgs; };
      };
    };
  }
)
