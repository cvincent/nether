{ name, mkSoftware, ... }:
mkSoftware name (
  { bat, ... }:
  {
    nixos.nether.shells.aliases.cat = "bat";
    hm.programs.bat = { inherit (bat) enable package; };
  }
)
