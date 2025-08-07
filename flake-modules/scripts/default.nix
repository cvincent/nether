applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  camelize = true;
}
