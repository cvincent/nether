{ name, mkSoftware, ... }:
mkSoftware name (
  { blueman, ... }:
  {
    nixos.services.blueman.enable = true;
  }
)
