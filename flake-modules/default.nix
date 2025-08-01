applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  exclude = [ "software" ];
  additionalImports = [ ./software ];
}
