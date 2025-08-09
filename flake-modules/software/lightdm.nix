{ name, mkSoftware, ... }:
mkSoftware name (
  { lightdm, ... }:
  {
    nixos.services.displayManager = {
      inherit (lightdm) enable;
      lightdm = { inherit (lightdm) enable; };
    };
  }
)
