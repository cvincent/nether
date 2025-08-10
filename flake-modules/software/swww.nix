{ name, mkSoftware, ... }:
mkSoftware name (
  { swww, ... }:
  {
    hm.services.swww = { inherit (swww) enable package; };
  }
)
