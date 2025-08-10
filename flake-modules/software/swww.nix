{ name, mkSoftware, ... }:
mkSoftware name (
  { swww, lib, ... }:
  {
    hm.services.swww = { inherit (swww) enable package; };
  }
)
