{ name, mkSoftware, ... }:
mkSoftware name (
  {
    nether,
    firefox,
    lib,
    ...
  }:
  {
    nixos.nether.backups.paths."${nether.homeDirectory}/.mozilla/firefox".deleteMissing = true;

    hm = {
      programs.firefox = {
        inherit (firefox) enable package;
      };
    };
  }
)
