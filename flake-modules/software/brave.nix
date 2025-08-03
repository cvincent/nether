{ name, mkSoftware, ... }:
mkSoftware name (
  {
    nether,
    brave,
    lib,
    ...
  }:
  {
    options.commandLineArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    nixos.nether.backups.paths."${nether.homeDirectory}/.config/BraveSoftware/Brave-Browser".deleteMissing =
      true;

    hm = {
      programs.brave = {
        enable = true;
        package = brave.package.override { inherit (brave) commandLineArgs; };
      };
    };
  }
)
