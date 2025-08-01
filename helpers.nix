{
  # TODO: Extract all of mkFeature into its own module
  nixosModule =
    { options, ... }:
    {
      home-manager.extraSpecialArgs.osOptions = options;
    };

  helpers = rec {
    getSoftwareNamespaces =
      lib: feature:
      # Feature attrs not included in the list below are assumed to be
      # namespaced attrsets of software definitions for this feature
      feature
      |> lib.attrsets.filterAttrs (
        softwareNamespace: _:
        !(lib.lists.elem softwareNamespace [
          "description"
          "options"
          "nixos"
          "hm"
        ])
      );

    softwareOptionDefs =
      {
        lib,
        pkgs,
        options,
        softwareName,
        softwareDef,
      }:
      (
        if options ? nether.software."${softwareName}" then
          # If a software module is defined, surface its options here, but
          # override enable to default to true
          options.nether.software."${softwareName}"
          // {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = options.nether.software."${softwareName}".enable.description;
            };
          }
        else if pkgs ? "${softwareName}" then
          # If named after a package, define default enable and package options
          {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = pkgs."${softwareName}".meta.description;
            };

            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs."${softwareName}";
            };
          }
        else
          # If we don't know what this is, the feature is on its own from here
          { }
      )
      // (softwareDef.options or { });

    mkFeature =
      featureName: featureDef:
      { lib, moduleWithSystem, ... }:
      {
        flake.nixosModules."${featureName}" = moduleWithSystem (
          systemArgs@{
            pkgs,
            pkgInputs,
            inputs',
            self',
            system,
          }:
          nixosModuleArgs@{ options, config, ... }:
          let
            thisConfig = config.nether."${featureName}";

            featureDefFn = if builtins.isFunction featureDef then featureDef else (_: featureDef);

            feature = (
              featureDefFn (
                systemArgs
                // nixosModuleArgs
                // {
                  "${featureName}" = thisConfig;
                  inherit (config) nether;
                }
              )
            );

            softwareNamespaces = getSoftwareNamespaces lib feature;
          in
          {
            options = {
              # Every feature has its own umbrella enable option, default false
              nether."${featureName}" = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = feature.description;
                };
              }
              // (
                softwareNamespaces
                |> lib.mapAttrs (
                  softwareNamespace: softwareDefs:
                  {
                    # Each software namespace gets its own enable option,
                    # default true
                    enable = lib.mkOption {
                      type = lib.types.bool;
                      description = (softwareDefs.description or "${featureName} ${softwareNamespace}");
                      default = true;
                    };
                  }
                  // (
                    # Attrs not included in the list below are assumed to be a
                    # single software definition
                    softwareDefs
                    |> lib.attrsets.filterAttrs (
                      softwareName: _:
                      !(lib.lists.elem softwareName [
                        "description"
                        "options"
                      ])
                    )
                    |> lib.mapAttrs (
                      softwareName: softwareDef:
                      softwareOptionDefs {
                        inherit
                          lib
                          pkgs
                          options
                          softwareName
                          softwareDef
                          ;
                      }
                    )
                  )
                  // (softwareDefs.options or { })
                )
              )
              // feature.options or { };
            };

            config = (lib.mkIf config.nether."${featureName}".enable) (
              lib.mkMerge (
                [ ]
                ++ (
                  # For each software namespace, and each software definition
                  # within them, if it refers to a nether.software module, pass
                  # our feature options through to the software module.
                  softwareNamespaces
                  |> lib.mapAttrsToList (
                    softwareNamespace: softwareDefs: {
                      nether.software = lib.mkIf thisConfig."${softwareNamespace}".enable (
                        softwareDefs
                        |> lib.filterAttrs (softwareName: _: options ? nether.software."${softwareName}")
                        |> lib.mapAttrs (
                          softwareName: _: { inherit (thisConfig."${softwareNamespace}"."${softwareName}") enable package; }
                        )
                      );
                    }
                  )
                )
                ++ (
                  # Include any nixos configs from enabled software definitions
                  softwareNamespaces
                  |> lib.attrsets.mapAttrsToList (
                    softwareNamespace: softwareDefs:
                    softwareDefs
                    |> lib.attrsets.mapAttrsToList (
                      softwareName: softwareDef:
                      lib.mkIf (
                        thisConfig."${softwareNamespace}".enable
                        && thisConfig."${softwareNamespace}"."${softwareName}".enable
                      ) (softwareDef.nixos or { })
                    )
                  )
                  |> lib.flatten
                )
                ++ [
                  (feature.nixos or { })
                ]
              )
            );
          }
        );

        flake.homeModules."${featureName}" = moduleWithSystem (
          systemArgs@{
            pkgs,
            pkgInputs,
            inputs',
            self',
            system,
          }:
          homeModuleArgs@{ osConfig, osOptions, ... }:
          let
            thisConfig = osConfig.nether."${featureName}";

            featureDefFn = if builtins.isFunction featureDef then featureDef else (_: featureDef);

            feature = featureDefFn (
              systemArgs
              // homeModuleArgs
              // {
                config = osConfig;
                "${featureName}" = thisConfig;
                inherit (osConfig) nether;
              }
            );

            softwareNamespaces = getSoftwareNamespaces lib feature;
          in
          {
            config = (lib.mkIf osConfig.nether."${featureName}".enable) (
              lib.mkMerge (
                [ ]
                ++ (
                  # For each software namespace, and each software definition
                  # within them, if it's not a nether.software module, but it is
                  # in pkgs, add the package to home.packages.
                  softwareNamespaces
                  |> lib.mapAttrsToList (
                    softwareNamespace: softwareDefs: {
                      home.packages = lib.optionals thisConfig."${softwareNamespace}".enable (
                        softwareDefs
                        |> lib.filterAttrs (
                          softwareName: _: !osOptions ? nether.software."${softwareName}" && pkgs ? "${softwareName}"
                        )
                        |> lib.mapAttrsToList (
                          softwareName: _:
                          lib.optional thisConfig."${softwareNamespace}"."${softwareName}".enable pkgs."${softwareName}"
                        )
                        |> lib.flatten
                      );
                    }
                  )
                )
                ++ [ (feature.hm or { }) ]
              )
            );
          }
        );
      };

    mkModuleDir =
      dir:
      {
        moduleArgs,
        applyArgs ? { },
        exclude ? [ ],
        additionalImports ? [ ],
      }:
      let
        inherit (moduleArgs) lib flake-parts-lib;
        excluded = exclude ++ [ "default.nix" ];
      in
      {
        imports =
          (
            dir
            |> builtins.readDir
            |> builtins.attrNames
            |> builtins.filter (f: !builtins.elem f excluded)
            |> builtins.map (
              module:
              flake-parts-lib.importApply (dir + "/${module}") (
                applyArgs // { name = lib.removeSuffix ".nix" module; }
              )
            )
          )
          ++ additionalImports;
      };
  };

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
