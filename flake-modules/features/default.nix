applyArgs@{ mkModuleDir, mkFeature, ... }:
moduleArgs@{ lib, flake-parts-lib, ... }:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  exclude = [ "mail" ];
}
