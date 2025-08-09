{ name, mkSoftware, ... }:
mkSoftware name (
  { gdm, ... }:
  {
    nixos.services.displayManager = {
      inherit (gdm) enable;
      gdm = { inherit (gdm) enable; };
    };
  }
)
