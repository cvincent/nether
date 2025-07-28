{
  flakeModuleHelpers =
    { lib, ... }:
    {
      _module.args.helpers = rec {
        # TODO: Make `which` style options easier and more consistent; write
        # this function
        whichOpt = (
          allowNull: default: pkgs:
          (
            {

            }
            // { }
          )
        );

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

        pkgOptPkg = (pkgOpt: lib.optional pkgOpt.enable pkgOpt.package);

        boolOpt =
          default: description:
          (lib.mkOption {
            type = lib.types.bool;
            inherit description default;
          });

        # Create a feature module package option that delegates to a software
        # module
        delegateToSoftware = (
          options: name: defaultEnable:
          let
            softwareOpts = options.nether.software."${name}";
          in
          (pkgOpt softwareOpts.package.default defaultEnable softwareOpts.enable.description)
        );
      };
    };

  homeModuleHelpers =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      _module.args.helpers = {
        directSymlink = (
          path:
          [
            "${osConfig.nether.homeDirectory}/dotfiles/"
            (
              path
              |> toString
              |> builtins.match "\/nix\/store\/[a-z0-9]+-source\/(.+)"
              |> lib.strings.concatStrings
            )
          ]
          |> lib.strings.concatStrings
          |> config.lib.file.mkOutOfStoreSymlink
        );
      };
    };
}
