{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    retroarch,
    lib,
    ...
  }:
  {
    options = lib.getAttrs [ "cores" "package" "settings" ] hmOptions.programs.retroarch;

    hm = {
      programs.retroarch = {
        inherit (retroarch)
          enable
          cores
          package
          settings
          ;
      };
    };
  }
)
