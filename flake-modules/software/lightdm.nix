{ name, mkSoftware, ... }:
mkSoftware name (
  { lightdm, ... }:
  {
    # TODO: Probably move to just services.xserver.displayManager, when we move
    # to UWSM, though not sure lightdm is available there
    nixos.services.displayManager = {
      inherit (lightdm) enable;
      lightdm = { inherit (lightdm) enable; };
    };
  }
)
