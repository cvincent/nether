{ name, mkSoftware, ... }:
mkSoftware name (
  {
    avizo,
    lib,
    pkgs,
    ...
  }:
  {
    options.settings = lib.mkOption {
      type = (pkgs.formats.ini { }).type;
      default.default.time = 0.5;
    };

    hm = {
      services.avizo = {
        inherit (avizo) enable package settings;
      };

      systemd.user.services.avizo = {
        Install.WantedBy = lib.mkForce [ "graphical.target" ];
        Unit = {
          After = lib.mkForce [ "graphical.target" ];
          PartOf = lib.mkForce [ "graphical.target" ];
        };
      };
    };
  }
)
