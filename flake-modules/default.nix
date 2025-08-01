applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir {
  dir = ./.;
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
