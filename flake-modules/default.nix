applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  exclude = [
    "scripts"
    "software"
  ];
  additionalImports = [
    ./scripts
    ./software
  ];
}
