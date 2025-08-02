{ name, mkSoftware, ... }:
mkSoftware name (
  { fastfetch, ... }:
  {
    hm.programs.fastfetch = { inherit (fastfetch) enable package; };
  }
)
