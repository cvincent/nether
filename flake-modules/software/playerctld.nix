{ name, mkSoftware, ... }:
mkSoftware name (
  { playerctld, pkgs, ... }:
  {
    package = pkgs.playerctl;

    hm.services.playerctld = {
      inherit (playerctld) enable package;
    };
  }
)
