{ name, mkSoftware, ... }:
mkSoftware name (
  { swww, lib, ... }:
  {
    hm = {
      services.swww = { inherit (swww) enable package; };

      systemd.user.services.swww = {
        Install.WantedBy = lib.mkForce [ "graphical.target" ];
        Unit.After = lib.mkForce [ "graphical.target" ];
        Unit.PartOf = lib.mkForce [ "graphical.target" ];
      };
    };
  }
)
