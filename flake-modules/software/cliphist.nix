{ name, mkSoftware, ... }:
mkSoftware name (
  { cliphist, ... }:
  {
    hm.services.cliphist = {
      inherit (cliphist) enable package;
      extraOptions = [
        "-max-items"
        "10000"
      ];
      systemdTargets = [ "graphical.target" ];
    };
  }
)
