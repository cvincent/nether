{ name, mkSoftware, ... }:
mkSoftware name (
  {
    flameshot,
    lib,
    pkgs,
    ...
  }:
  {
    package = (pkgs.flameshot.override { enableWlrSupport = true; });

    hm = {
      services.flameshot = { inherit (flameshot) enable package; };

      systemd.user.services.flameshot = {
        Install.WantedBy = lib.mkForce [ "graphical.target" ];
        Unit.After = lib.mkForce [ "graphical.target" ];
        Unit.PartOf = lib.mkForce [ "graphical.target" ];
      };
    };
  }
)
