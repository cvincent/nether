{ name, mkSoftware, ... }:
mkSoftware name (
  { gdm, ... }:
  {
    # TODO: Probably move to just services.xserver.displayManager, when we move
    # to UWSM
    services.xserver.displayManager = {
      inherit (gdm) enable;
      gdm = { inherit (gdm) enable; };
    };
  }
)
