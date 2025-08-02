{ name, mkSoftware, ... }:
mkSoftware name (
  { gh, ... }:
  {
    hm.programs.gh = { inherit (gh) enable package; };
  }
)
