{ name, mkSoftware, ... }:
mkSoftware name (
  {
    fuzzel,
    lib,
    pkgs,
    ...
  }:
  {
    options = {
      settings = lib.mkOption {
        type = (pkgs.formats.ini { }).type;
        default = {
          # TODO: Not sure if this belongs here... Stylix really kind of stops
          # at fonts and colors it seems, but we define borders for the WM,
          # utilities like Fuzzel, our bar, etc. Think about this when we return
          # to theming.
          border.width = 5;
        };
      };
    };

    hm.programs.fuzzel = {
      inherit (fuzzel) enable package settings;
    };
  }
)
