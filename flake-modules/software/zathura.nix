{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    zathura,
    lib,
    ...
  }:
  {
    options = lib.getAttrs [ "options" "mappings" "extraConfig" ] hmOptions.programs.zathura;
    hm.programs.zathura = { inherit (zathura) enable package; };
  }
)
