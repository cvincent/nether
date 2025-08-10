applyArgs@{ mkModuleDir, ... }: moduleArgs: mkModuleDir ./. { inherit applyArgs moduleArgs; }
