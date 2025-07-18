{
  flakeModuleHelpers =
    { lib, ... }:
    {
      _module.args.helpers = {
        pkgOpt = (
          pkg: default: description: {
            enable = lib.mkOption {
              type = lib.types.bool;
              inherit description default;
            };

            package = lib.mkOption {
              type = lib.types.package;
              default = pkg;
            };
          }
        );

        boolOpt =
          default: description:
          lib.mkOption {
            type = lib.types.bool;
            inherit description default;
          };
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
