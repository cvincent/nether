applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  exclude = [ "mail" ];
  camelize = true;
}
