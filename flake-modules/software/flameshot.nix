{ name, mkSoftware, ... }:
mkSoftware name (
  { flameshot, pkgs, ... }:
  {
    package = (pkgs.flameshot.override { enableWlrSupport = true; });
    hm.services.flameshot = { inherit (flameshot) enable package; };
  }
)
