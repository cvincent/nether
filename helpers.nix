{
  flakeModuleHelpers =
    { lib, ... }:
    {
      _module.args.helpers = {
        pkgOpt = (
          pkg: default: desc: {
            enable = lib.mkOption {
              type = lib.types.bool;
              description = desc;
              inherit default;
            };

            package = lib.mkOption {
              type = lib.types.package;
              default = pkg;
            };
          }
        );
      };
    };

  homeModuleHelpers =
    { config, ... }:
    {
      _module.args.helpers = {
        directSymlink = (path: config.lib.file.mkOutOfStoreSymlink (toString path));
      };
    };
}
