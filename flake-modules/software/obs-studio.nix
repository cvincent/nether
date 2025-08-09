{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    obs-studio,
    lib,
    ...
  }:
  {
    options = lib.getAttrs [ "plugins" ] hmOptions.programs.obs-studio;

    hm.programs.obs-studio = {
      inherit (obs-studio) enable package plugins;
    };
  }
)
